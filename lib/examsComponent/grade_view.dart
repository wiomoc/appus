import 'package:campus_flutter/base/networking/apis/campUSApi/campus_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../base/helpers/icon_text.dart';
import '../base/helpers/string_parser.dart';
import '../gradeComponent/viewModels/grade_viewmodel.dart';

class AchievementRow extends StatelessWidget {
  final Achievement grade;

  const AchievementRow(this.grade, {super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: grade.valid? 1: 0.3,
        child: ListTile(
            leading: GradeRectangle(grade: grade.grade),
            title: Text(grade.localizedCourseName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconText(
                    iconData: Icons.date_range,
                    label: "${DateFormat.MMMd().format(grade.dateTime)} - ${grade.localizedSemester}", //grade.lvNumber,
                    iconColor: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).colorScheme.secondary),
                const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                IconText(
                    iconData: Icons.book_outlined,
                    label: "${grade.localizedStudyName} - ${grade.localizedDegreeName}",
                    iconColor: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).colorScheme.secondary),
              ],
            )));
  }
}

class GradeRectangle extends StatelessWidget {
  final String? grade;

  const GradeRectangle({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    final parsedGrade = grade != null ? StringParser.optStringToOptDouble(grade) ?? grade : "n/a";
    return AspectRatio(
        aspectRatio: 1.0,
        child: Container(
            decoration:
                BoxDecoration(color: GradeViewModel.getColor(parsedGrade), borderRadius: BorderRadius.circular(4)),
            child: Center(
              child: Text(
                parsedGrade is double ? parsedGrade.toStringAsFixed(1) : parsedGrade.toString(),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white, shadows: [const Shadow(color: Colors.black, blurRadius: 10.0)]),
              ),
            )));
  }
}
