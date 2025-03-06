import 'package:campus_flutter/base/helpers/api_backed_state.dart';
import 'package:campus_flutter/courseComponent/model/course_summary.dart';
import 'package:flutter/material.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

import '../api/my_courses.dart';
import 'course_view.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() {
    return _CoursePageState();
  }
}

class _CoursePageState extends ApiBackedState<List<CourseSummary>, CoursesPage> with ApiPullRefresh  {
  @override
  void initState() {
    super.initState();
    load(MyCoursesApiOperation(), const Duration(hours: 1));
  }

  @override
  Widget build(BuildContext context) => body();

  @override
  Widget buildBody(List<CourseSummary> courses) {
    if (courses.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.courseNotSelectedForCurrentSemester));
    }
    return ListView.separated(
        itemBuilder: (context, index) => ListTile(
              title: Text(courses[index].localizedTitle),
              subtitle: Text(
                "${courses[index].localizedType} - ${courses[index].localizedStudyProgramme}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => CoursePage(courseId: courses[index].id)));
              },
            ),
        separatorBuilder: (context, index) => const Divider(),
        itemCount: courses.length);
  }

  @override
  String get resourceName => AppLocalizations.of(context)!.courses;
}
