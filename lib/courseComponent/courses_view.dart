import 'package:campus_flutter/base/helpers/retryable.dart';
import 'package:campus_flutter/base/networking/apis/campUSApi/campus_api.dart';
import 'package:campus_flutter/base/views/generic_stream_builder.dart';
import 'package:flutter/material.dart';

import '../base/helpers/delayed_loading_indicator.dart';
import '../base/views/error_handling_view.dart';
import '../providers_get_it.dart';
import 'course_view.dart';

class CoursesView extends StatefulWidget {
  const CoursesView({super.key});

  @override
  CourseState createState() {
    return CourseState();
  }
}

class CourseState extends State<CoursesView> {
  late Retryable<List<CourseSummary>> _coursesRetryable;

  @override
  void initState() {
    super.initState();

    _coursesRetryable = Retryable(() async {
      final api = getIt<CampusApi>();
      return await api.myCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GenericStreamBuilder(
        stream: _coursesRetryable.stream,
        dataBuilder: (context, courses) {
          if (courses.isEmpty) {
            return const Center(child: Text("No courses selected for the current semester yet."));
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
                          context, MaterialPageRoute(builder: (context) => CourseView(courseId: courses[index].id)));
                    },
                  ),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: courses.length);
        },
        errorBuilder: (context, error) => ErrorHandlingView(
              error: error,
              errorHandlingViewType: ErrorHandlingViewType.fullScreen,
              retry: (force) {
                _coursesRetryable.retry();
              },
            ),
        loadingBuilder: (context) => const DelayedLoadingIndicator(name: "Courses"));
  }
}
