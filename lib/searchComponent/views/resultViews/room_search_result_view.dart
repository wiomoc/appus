import 'package:campus_flutter/base/helpers/api_operation.dart';
import 'package:campus_flutter/courseComponent/model/course_summary.dart';
import 'package:campus_flutter/mapComponent/map_view.dart';
import 'package:campus_flutter/mapComponent/model/room_search_entry.dart';
import 'package:flutter/material.dart';

import '../../../courseComponent/api/courses_search.dart';
import '../../../courseComponent/course_view.dart';
import '../../../mapComponent/api/room_search_api.dart';
import 'base_search_result_view.dart';

class RoomSearchResultView extends BaseSearchResultView<RoomSearchEntry> {
  const RoomSearchResultView({super.key, required super.searchText});

  @override
  AbstractApiOperation<List<RoomSearchEntry>> search() => RoomSearchApiOperation(searchText);

  @override
  String get title => "Rooms";

  @override
  Widget buildResultEntry(BuildContext context, RoomSearchEntry entry) {
    return ListTile(
        title: Text(entry.code),
        subtitle: Text(entry.address),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => MapPageView(roomId: entry.id)));
        });
  }
}
