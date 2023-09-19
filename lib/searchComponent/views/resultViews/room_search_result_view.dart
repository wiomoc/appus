import 'package:campus_flutter/base/helpers/api_operation.dart';
import 'package:campus_flutter/mapComponent/model/room_search_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../mapComponent/api/room_search_api.dart';
import '../../../mapComponent/views/room_location_page.dart';
import 'base_search_result_view.dart';

class RoomSearchResultView extends BaseSearchResultView<RoomSearchEntry> {
  const RoomSearchResultView({super.key, required super.searchText});

  @override
  AbstractApiOperation<List<RoomSearchEntry>> search() => RoomSearchApiOperation(searchText);

  @override
  String getTitle(BuildContext context) =>  AppLocalizations.of(context)!.mapRooms;

  @override
  Widget buildResultEntry(BuildContext context, RoomSearchEntry entry) {
    return ListTile(
        title: Text(entry.code),
        subtitle: Text(entry.address),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoomLocationPage(roomId: entry.id)));
        });
  }
}
