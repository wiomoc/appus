import 'package:campus_flutter/searchComponent/model/comparison_token.dart';
import 'package:campus_flutter/searchComponent/model/search_exception.dart';
import 'package:campus_flutter/searchComponent/protocols/global_search.dart';
import 'package:campus_flutter/searchComponent/protocols/searchable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rxdart/rxdart.dart';
/*
class StudyRoomSearchViewModel {
  BehaviorSubject<List<(StudyRoomSearchResult, Distances)>?> searchResults =
      BehaviorSubject.seeded(null);

  StudyRoomData? studyRoomData;

  Future studyRoomSearch(
      {bool forcedRefresh = false, required String query}) async {
    if (studyRoomData == null) {
      return StudyRoomsService.fetchStudyRooms(forcedRefresh).then((value) {
        studyRoomData = value.$2;
        _search(query);
      }, onError: (error) => searchResults.addError(error));
    } else {
      _search(query);
    }
  }

  void _search(String query) {
    if (studyRoomData?.groups == null || studyRoomData?.rooms == null) {
      searchResults.addError(SearchException.empty(searchQuery: query));
      return;
    }

    final List<StudyRoomSearchResult> groupRooms = studyRoomData?.groups
            ?.map((e) {
          final currentRooms = studyRoomData?.rooms
                  ?.where((element) => e.rooms?.contains(element.id) ?? false)
                  .toList() ??
              [];
          return StudyRoomSearchResult(e, currentRooms);
        }).toList() ??
        [];

    final results = GlobalSearch.tokenSearch(query, groupRooms);
    if (results == null) {
      searchResults.addError(SearchException.empty(searchQuery: query));
    } else {
      searchResults.add(results);
    }
  }
}

class StudyRoomSearchResult extends Searchable {
  final StudyRoomGroup studyRoomGroup;
  final List<StudyRoom> studyRooms;

  StudyRoomSearchResult(this.studyRoomGroup, this.studyRooms);

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ComparisonToken> get comparisonTokens => [
        ...studyRoomGroup.comparisonTokens,
        ...studyRooms.expand((element) => element.comparisonTokens)
      ];
}
*/