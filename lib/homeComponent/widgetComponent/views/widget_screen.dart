import 'package:campus_flutter/base/enums/home_widget.dart';
import 'package:campus_flutter/calendarComponent/views/homeWidget/calendar_widget_view.dart';
import 'package:campus_flutter/departuresComponent/views/homeWidget/departures_widget_view.dart';
import 'package:campus_flutter/homeComponent/widgetComponent/recommender/spatial_temporal_strategy.dart';
import 'package:campus_flutter/homeComponent/widgetComponent/recommender/widget_recommender.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WidgetScreen extends ConsumerStatefulWidget {
  const WidgetScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WidgetScreenState();
}

class _WidgetScreenState extends ConsumerState<WidgetScreen> {
  late Future<Map<HomeWidget, int>> recommendations;

  @override
  initState() {
    super.initState();
    recommendations = WidgetRecommender(SpatialTemporalStrategy()).fetchRecommendations(ref);
  }

  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      //const CafeteriaWidgetView(),
      CalendarHomeWidgetView(),
      DeparturesHomeWidget(),
      //const StudyRoomWidgetView.closest()
    ]);
  }
}
