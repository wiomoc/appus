import 'package:flutter/material.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

import 'detailed_course_info_row_view.dart';
import '../model/course_detail.dart';

class DetailedCourseInfoView extends StatelessWidget {
  final CourseDetail courseDetails;

  const DetailedCourseInfoView({super.key, required this.courseDetails});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (courseDetails.localizedCourseContent != null) ...[
          DetailedCourseInfoRowView(title: AppLocalizations.of(context)!.courseContents,
              information: courseDetails.localizedCourseContent!)
        ],
        if (courseDetails.localizedCourseObjective != null) ...[
          const Divider(),
          DetailedCourseInfoRowView(title: AppLocalizations.of(context)!.courseObjectives,
              information: courseDetails.localizedCourseObjective!)
        ],
      ],
    );
  }
}