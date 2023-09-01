import 'package:campus_flutter/base/networking/apis/campUSApi/campus_api.dart';
import 'package:flutter/material.dart';

import 'basic_course_info_row_view.dart';

class BasicCourseInfoView extends StatelessWidget {
  final CourseDetail courseDetails;
  final List<String> lecturerNames;

  const BasicCourseInfoView({super.key, required this.courseDetails, required this.lecturerNames});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      BasicCourseInfoRowView(information: courseDetails.courseNumber, iconData: Icons.numbers),
      ...lecturerNames.expand((lecturer) => [
        const Divider(),
        BasicCourseInfoRowView(information: lecturer, iconData: Icons.person)
      ]),
      const Divider(),
      BasicCourseInfoRowView(information: courseDetails.localizedType, iconData: Icons.edit_note),
      const Divider(),
      BasicCourseInfoRowView(information: "${courseDetails.semesterHours} SWS", iconData: Icons.hourglass_top),
      const Divider(),
      BasicCourseInfoRowView(information: courseDetails.localizedSemester, iconData: Icons.school),
      const Divider(),
      BasicCourseInfoRowView(information: courseDetails.localizedOrganisation, iconData: Icons.account_tree),
      const Divider(),
      BasicCourseInfoRowView(information: courseDetails.localizedLanguage, iconData: Icons.translate),
    ]);
  }
}
