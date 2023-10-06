import 'package:campus_flutter/base/helpers/api_backed_state.dart';
import 'package:campus_flutter/base/helpers/api_operation.dart';
import 'package:campus_flutter/examsComponent/api/my_achievements.dart';
import 'package:campus_flutter/examsComponent/api/my_registered_exams.dart';
import 'package:campus_flutter/examsComponent/grade_view.dart';
import 'package:campus_flutter/examsComponent/model/achievement.dart';
import 'package:campus_flutter/examsComponent/model/planned_exam.dart';
import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../base/helpers/icon_text.dart';
import '../mapComponent/views/room_location_page.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ExamsScreenState();
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
                        builder: (context) => RoomLocationPage(roomId: exam.roomId!),
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

class _ExamsScreenState extends ApiBackedState<(List<PlannedExam>?, List<Achievement>?), ExamsScreen>
    with ApiBackedPageState {

  @override
  void initState() {
    super.initState();
    load(MergedApiOperation(MyRegisteredExamsApiOperation(), MyAchievementsApiOperation()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar(), body: body());
  }

  @override
  Widget buildBody((List<PlannedExam>?, List<Achievement>?) data) {
    if ((data.$1?.isEmpty ?? true) && (data.$2?.isEmpty ?? true)) {
      return Center(child: Text(AppLocalizations.of(context)!.examsAndGradesEmpty));
    }
    return ListView(
      children: [
        if (data.$1 != null && data.$1!.isNotEmpty)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Text(AppLocalizations.of(context)!.examsAndGradesRegistered)),
        if (data.$1 != null && data.$1!.isNotEmpty)
          ...data.$1!.mapIndexedAndLast((i, plannedExam, last) => Column(children: [
                PlannedExamRow(plannedExam),
                if (!last)
                  Divider(
                    height: 1,
                    color: Colors.black.withOpacity(0.08),
                  )
              ])),
        if (data.$2 != null)
          ...data.$2!.groupListsBy((element) => element.localizedSemester).entries.expand((entry) => [
                const Divider(),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Text(entry.key)),
                ...entry.value.map((achievement) => AchievementRow(achievement))
              ])
      ],
    );
  }

  @override
  String get resourceName => AppLocalizations.of(context)!.examsAndGrades;
}
