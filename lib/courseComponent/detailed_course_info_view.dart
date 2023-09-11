import 'package:flutter/material.dart';

import 'detailed_course_info_row_view.dart';
import 'model/course_detail.dart';

class DetailedCourseInfoView extends StatelessWidget {
  final CourseDetail courseDetails;

  const DetailedCourseInfoView({super.key, required this.courseDetails});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (courseDetails.localizedCourseContent != null) ...[
          DetailedCourseInfoRowView(title: "Course Contents",
              information: courseDetails.localizedCourseContent!)
        ],
        if (courseDetails.localizedCourseObjective != null) ...[
          const Divider(),
          DetailedCourseInfoRowView(title: "Course Objective",
              information: courseDetails.localizedCourseObjective!)
        ],
      ],
    );
  }
}