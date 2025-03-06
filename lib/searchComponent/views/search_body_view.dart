import 'package:campus_flutter/base/helpers/horizontal_slider.dart';
import 'package:campus_flutter/searchComponent/views/resultViews/building_search_result_view.dart';
import 'package:campus_flutter/searchComponent/views/resultViews/room_search_result_view.dart';
import 'package:campus_flutter/searchComponent/views/search_textfield_view.dart';
import 'package:flutter/material.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

import 'resultViews/course_search_result_view.dart';

class SearchView extends StatefulWidget {
  final int index;

  const SearchView({super.key, required this.index});

  @override
  State<StatefulWidget> createState() {
    return _SearchViewState();
  }
}

class _SearchViewState extends State<SearchView> {
  final List<SearchCategory> _selectedCategories = [];
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    if (widget.index == 0) {
      _selectedCategories.add(SearchCategory.rooms);
      _selectedCategories.add(SearchCategory.lectures);
    } else if (widget.index == 2) {
      _selectedCategories.add(SearchCategory.lectures);
    } else if (widget.index == 4) {
      _selectedCategories.add(SearchCategory.rooms);
      _selectedCategories.add(SearchCategory.buildings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SearchTextField(
        onTextUpdate: (search) {
          setState(() {
            _searchText = search;
          });
        },
        index: widget.index,
      ),
      if (widget.index == 0) _categoryChooser(),
      _search()
    ]);
  }

  Widget _search() {
    return Expanded(
        child: (_searchText.isEmpty)
            ? Center(child: Text(AppLocalizations.of(context)!.searchEnterQuery))
            : (_selectedCategories.isEmpty)
                ? Center(child: Text(AppLocalizations.of(context)!.searchSelectCategories))
                : Scrollbar(
                    child: SingleChildScrollView(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                    for (var result in _selectedCategories) _searchResultViewBuilder(result),
                  ]))));
  }

  Widget _categoryChooser() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: HorizontalSlider(
            data: SearchCategory.values.toList(),
            height: 40,
            child: (searchCategory) => FilterChip.elevated(
                  label: Text(searchCategory.localizedTitle(context)),
                  onSelected: (selected) {
                    if (selected) {
                      _addCategory(searchCategory);
                    } else {
                      _removeCategory(searchCategory);
                    }
                    //ref.read(searchViewModel).triggerSearchAfterUpdate(null, null);
                  },
                  selected: _selectedCategories.contains(searchCategory),
                )));
  }

  void _addCategory(SearchCategory searchCategory) {
    if (!_selectedCategories.contains(searchCategory)) {
      setState(() {
        _selectedCategories.add(searchCategory);
        if (_searchText.isEmpty) {
          //search(index, searchString);
        }
      });
    }
  }

  void _removeCategory(SearchCategory searchCategory) {
    if (_selectedCategories.contains(searchCategory)) {
      setState(() {
        _selectedCategories.remove(searchCategory);
        if (_searchText.isEmpty) {
          //search(index, searchString);
        }
      });
    }
  }

  Widget _searchResultViewBuilder(SearchCategory searchCategory) {
    switch (searchCategory) {
      // case SearchCategory.grade:
      //  return const GradeSearchResultView(key: ValueKey("gradeSearchResultView"));
      // case SearchCategory.cafeterias:
      //   return const CafeteriasSearchResultView(key: ValueKey("cafeteriasSearchResultView"));
      // case SearchCategory.calendar:
      //   return const CalendarSearchResultView(key: ValueKey("calendarSearchResultView"));
      //case SearchCategory.studyRoom:
      //  return const StudyRoomSearchResultView();
      case SearchCategory.lectures:
        return CourseSearchResultView(searchText: _searchText, key: const ValueKey("lectureSearchResultView"));
      case SearchCategory.rooms:
        return RoomSearchResultView(searchText: _searchText, key: const ValueKey("roomsSearchResultView"));
      case SearchCategory.buildings:
        return BuildingSearchResultView(searchText: _searchText, key: const ValueKey("buildingsSearchResultView"));
      default:
        return Container();
    }
  }
}

enum SearchCategory {
  lectures,
  rooms,
  buildings;

  String localizedTitle(BuildContext context) {
    switch (this) {
      case SearchCategory.lectures:
        return AppLocalizations.of(context)!.courses;
      case SearchCategory.rooms:
        return AppLocalizations.of(context)!.mapRooms;
      case SearchCategory.buildings:
        return AppLocalizations.of(context)!.mapBuildings;
      default:
        return "";
    }
  }
}
