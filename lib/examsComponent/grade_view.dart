import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

import '../base/helpers/icon_text.dart';
import '../base/helpers/string_parser.dart';
import '../gradeComponent/viewModels/grade_viewmodel.dart';
import 'model/achievement.dart';

class AchievementRow extends StatelessWidget {
  final Achievement grade;

  const AchievementRow(this.grade, {super.key});

  String _titleText(BuildContext context) {
    if(grade.localizedCourseName.isNotEmpty && grade.localizedCourseName != "-") {
      return grade.localizedCourseName;
    } else {
      switch(grade.type) {
        case AchievementType.exam:
          return AppLocalizations.of(context)!.examsExam;
        case AchievementType.thesis:
          return AppLocalizations.of(context)!.examsThesis;
      }
    }
  }

  String get _dateText {
    final dateTime = grade.dateTime;
    if(dateTime != null) {
      return "${DateFormat.MMMd().format(dateTime)} - ${grade.localizedSemester}";
    } else {
      return grade.localizedSemester;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: grade.valid? 1: 0.3,
        child: ListTile(
            leading: GradeRectangle(grade: grade.grade),
            title: Text(_titleText(context)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconText(
                    iconData: Icons.date_range,
                    label: _dateText,
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
    final parsedGrade = grade != null ? StringParser.optStringToOptDouble(grade) ?? grade : AppLocalizations.of(context)!.examsAndGradesNoGrade;
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
