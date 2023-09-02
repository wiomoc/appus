import 'package:campus_flutter/base/enums/home_widget.dart';
import 'package:campus_flutter/calendarComponent/views/homeWidget/calendar_widget_view.dart';
import 'package:campus_flutter/departuresComponent/views/homeWidget/departures_widget_view.dart';
import 'package:campus_flutter/homeComponent/widgetComponent/recommender/spatial_temporal_strategy.dart';
import 'package:campus_flutter/homeComponent/widgetComponent/recommender/widget_recommender.dart';
import 'package:campus_flutter/placesComponent/views/homeWidget/cafeteria_widget_view.dart';
import 'package:campus_flutter/placesComponent/views/homeWidget/study_room_widget_view.dart';
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
    return Column(children: [
      const CafeteriaWidgetView(),
      const CalendarHomeWidgetView(),
      const DeparturesHomeWidget(),
      const StudyRoomWidgetView.closest()
    ]);
  }
}
