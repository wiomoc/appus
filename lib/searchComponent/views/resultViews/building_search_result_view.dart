import 'dart:math';

import 'package:campus_flutter/base/helpers/api_backed_state.dart';
import 'package:campus_flutter/mapComponent/api/tik_building_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../base/helpers/padded_divider.dart';
import '../../../base/views/error_handling_view.dart';
import '../../../homeComponent/widgetComponent/views/widget_frame_view.dart';
import '../../../mapComponent/model/building_summary.dart';
import '../../../mapComponent/views/building_location_page.dart';

class BuildingSearchResultView extends StatefulWidget {
  final String searchText;

  const BuildingSearchResultView({super.key, required this.searchText});

  @override
  State<StatefulWidget> createState() {
    return _BuildingSearchResultView();
  }
}

class _BuildingSearchResultView extends ApiBackedState<List<BuildingSummary>, BuildingSearchResultView> {
  @override
  void initState() {
    super.initState();
    load(TikBuildingApiOperation(), const Duration(days: 7));
  }

  @override
  Widget build(BuildContext context) {
    return WidgetFrameView(title: AppLocalizations.of(context)!.mapBuilding, child: Card(child: body()));
  }

  @override
  ErrorHandlingViewType get errorHandlingViewType => ErrorHandlingViewType.descriptionOnly;

  @override
  String get resourceName => AppLocalizations.of(context)!.mapBuilding;

  @override
  Widget? buildBody(List<BuildingSummary> data) {
    final searchText = widget.searchText.toLowerCase().replaceAll("pwr", "pfaffenwaldring");
    final filteredBuildings =
    data.where((element) => element.street.toLowerCase().contains(searchText)).toList();
    if (filteredBuildings.isNotEmpty) {
      return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) => _buildResultEntry(context, filteredBuildings[index]),
          separatorBuilder: (context, index) =>
          const PaddedDivider(
            height: 0,
          ),
          itemCount: min(filteredBuildings.length, 5));
    } else {
      return SizedBox(height: 100, child: Center(child: Text(AppLocalizations.of(context)!.searchNoResults)));
    }
  }

  Widget _buildResultEntry(BuildContext context, BuildingSummary entry) {
    return ListTile(
        title: Text(entry.street),
        subtitle: Text(entry.city),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => BuildingLocationPage(aref: entry.aref)));
        });
  }
}
