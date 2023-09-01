import 'package:campus_flutter/base/helpers/retryable.dart';
import 'package:campus_flutter/base/networking/apis/campUSApi/campus_api.dart';
import 'package:campus_flutter/base/views/generic_stream_builder.dart';
import 'package:campus_flutter/examsComponent/grade_view.dart';
import 'package:campus_flutter/mapComponent/map_view.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../base/helpers/delayed_loading_indicator.dart';
import '../base/helpers/icon_text.dart';
import '../base/views/error_handling_view.dart';
import '../providers_get_it.dart';

class ExamsView extends StatefulWidget {
  const ExamsView({super.key});

  @override
  State<StatefulWidget> createState() {
    return ExamsState();
  }
}

class PlannedExamRow extends StatelessWidget {
  final PlannedExam exam;

  const PlannedExamRow(this.exam, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: exam.date != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    exam.date!.day.toString().padLeft(2, "0"),
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Text(DateFormat.yMMM().format(exam.date!), style: Theme.of(context).textTheme.bodySmall)
                ],
              )
            : null,
        title: Text(exam.courseName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exam.deregistrationEnd != null)
              IconText(
                  iconData: Icons.event_busy_outlined,
                  label: DateFormat.yMMMd().format(exam.deregistrationEnd!), //grade.lvNumber,
                  iconColor: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).colorScheme.secondary),
            if (exam.examers.isNotEmpty)
              IconText(
                  iconData: Icons.person,
                  label: exam.examers.join(", "),
                  iconColor: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).colorScheme.secondary),
            if (exam.roomName != null)
              InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MapPageView(roomId: exam.roomId!),
                      )),
                  child: IconText(
                      iconData: Icons.room,
                      label: exam.roomName!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.dotted),
                      iconColor: Theme.of(context).primaryColor)),
          ],
        ));
  }
}

class ExamsState extends State<ExamsView> {
  late Retryable<(List<PlannedExam>, List<Achievement>)> _examsRetryable;

  @override
  void initState() {
    super.initState();
    _examsRetryable = Retryable(() async {
      final api = getIt<CampusApi>();

      return (await api.myRegisteredExams(), await api.myAchievements());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text("Exams & Grades"),
        ),
        body: GenericStreamBuilder(
            stream: _examsRetryable.stream,
            dataBuilder: (context, exams) {
              if (exams.$1.isEmpty && exams.$2.isEmpty) {
                return const Center(child: Text("No exams yet"));
              }
              return ListView(
                children: [
                  if (exams.$1.isNotEmpty)
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 5), child: Text("Angemeldet")),
                  ...exams.$1.mapIndexedAndLast((i, plannedExam, last) => Column(children: [
                        PlannedExamRow(plannedExam),
                        if (!last)
                          Divider(
                            height: 1,
                            color: Colors.black.withOpacity(0.08),
                          )
                      ])),
                  ...exams.$2.groupListsBy((element) => element.localizedSemester).entries.expand((entry) => [
                        Divider(),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Text(entry.key)),
                        ...entry.value.map((achievement) => AchievementRow(achievement))
                      ])
                ],
              );
            },
            errorBuilder: (context, error) => ErrorHandlingView(
                  error: error,
                  errorHandlingViewType: ErrorHandlingViewType.fullScreen,
                  retry: (force) {
                    _examsRetryable.retry();
                  },
                ),
            loadingBuilder: (context) => const DelayedLoadingIndicator(name: "Exams")));
  }
}
