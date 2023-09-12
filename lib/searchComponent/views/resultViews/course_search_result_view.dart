import 'package:campus_flutter/base/helpers/api_operation.dart';
import 'package:campus_flutter/courseComponent/model/course_summary.dart';
import 'package:flutter/material.dart';

import '../../../courseComponent/api/courses_search.dart';
import '../../../courseComponent/course_view.dart';
import 'base_search_result_view.dart';

class LectureSearchResultView extends BaseSearchResultView<CourseSummary> {
  const LectureSearchResultView({super.key, required super.searchText});

  @override
  AbstractApiOperation<List<CourseSummary>> search() => CoursesSearchApiOperation(searchText);

  @override
  String get title => "Courses";

  @override
  Widget buildResultEntry(BuildContext context, CourseSummary entry) {
    return ListTile(
        title: Text(entry.localizedTitle),
        subtitle: Text(entry.localizedType),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => CoursePage(courseId: entry.id)));
        });
  }
}
