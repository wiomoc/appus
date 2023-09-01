import 'package:campus_flutter/placesComponent/views/mensa/mensas_view.dart';
import 'package:flutter/material.dart';

import 'calendar2Component/calendars_view.dart';
import 'courseComponent/course_view.dart';
import 'courseComponent/courses_view.dart';
import 'examsComponent/exams_view.dart';
import 'mapComponent/map_view.dart';
import 'organisationsComponent/organisations_view.dart';





main() async {
  runApp(MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: const CalendarsView(),
  ));
}
