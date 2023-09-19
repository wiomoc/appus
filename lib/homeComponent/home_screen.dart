import 'package:flutter/material.dart';

import '../base/helpers/padded_divider.dart';
import '../calendarComponent/views/homeWidget/calendar_widget_view.dart';
import '../departuresComponent/views/homeWidget/departures_widget_view.dart';
import '../mensaComponent/views/homeWidget/mensa_widget_view.dart';
import '../updatesComponent/views/homeWidget/news_widget_view.dart';
import 'contactComponent/views/contact_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(children: const [
      ContactScreen(),
      PaddedDivider(),
      CalendarHomeWidgetView(),
      MensaWidgetView(),
      NewsHomeWidget(),
      DeparturesHomeWidget()]);
  }
}
