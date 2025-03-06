import 'dart:math';

import 'package:campus_flutter/base/helpers/api_backed_state.dart';
import 'package:campus_flutter/base/helpers/card_with_padding.dart';
import 'package:campus_flutter/base/views/error_handling_view.dart';
import 'package:campus_flutter/homeComponent/widgetComponent/views/widget_frame_view.dart';
import 'package:flutter/material.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

import '../../api/vvs_departures.dart';
import '../../departures_service.dart';
import '../../model/departure.dart';
import '../departures_details_row_view.dart';
import '../departures_details_view.dart';

class DeparturesHomeWidget extends StatefulWidget {
  const DeparturesHomeWidget({super.key});

  @override
  State<DeparturesHomeWidget> createState() => _DeparturesHomeWidgetState();
}

class _DeparturesHomeWidgetState extends ApiBackedState<List<Departure>, DeparturesHomeWidget> {
  Station? _station;

  @override
  void initState() {
    super.initState();
    getLastStation().then((value) => setState(() {
          _station = value;
          load(DeparturesApiOperation(value), const Duration(minutes: 5));
        }));
  }

  // TODO: make nice
  @override
  Widget build(BuildContext context) => WidgetFrameView(
      title:  AppLocalizations.of(context)!.departures + (_station != null ? " @ ${_station!.name}" : ""),
      child: GestureDetector(
          onTap: () => _onWidgetPressed(context),
          child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.2),
              child: CardWithPadding(child: body()))));

  @override
  Widget? buildBody(List<Departure> data) {
    return ListView.separated(
        itemCount: min(data.length, 4),
        shrinkWrap: true,
        separatorBuilder: (context, index) => const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        itemBuilder: (context, index) => DeparturesDetailsRowView(departure: data[index]));
  }

  _onWidgetPressed(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DeparturesPage()));
  }

  @override
  String get resourceName => AppLocalizations.of(context)!.departures;

  @override
  ErrorHandlingViewType get errorHandlingViewType => ErrorHandlingViewType.descriptionOnly;
}
