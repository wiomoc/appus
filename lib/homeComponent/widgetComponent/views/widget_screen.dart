import 'package:campus_flutter/base/enums/home_widget.dart';
import 'package:campus_flutter/placesComponent/views/mensa/homeWidget/mensa_widget_view.dart';
import 'package:flutter/material.dart';

import '../../../calendarComponent/homeWidget/calendar_widget_view.dart';
import '../../../vvsComponent/views/homeWidget/departures_widget_view.dart';

class WidgetScreen extends StatefulWidget {
  const WidgetScreen({super.key});

  @override
  State<WidgetScreen> createState() => _WidgetScreenState();
}

class _WidgetScreenState extends State<WidgetScreen> {
  late Future<Map<HomeWidget, int>> recommendations;

  @override
  initState() {
    super.initState();
    //recommendations = WidgetRecommender(SpatialTemporalStrategy()).fetchRecommendations(ref);
  }

  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      MensaWidgetView(),
      CalendarHomeWidgetView(),
      DeparturesHomeWidget(),
      //const StudyRoomWidgetView.closest()
    ]);
  }
}
