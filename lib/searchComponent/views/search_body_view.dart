import 'package:campus_flutter/base/helpers/horizontal_slider.dart';
import 'package:campus_flutter/searchComponent/views/resultViews/room_search_result_view.dart';
import 'package:campus_flutter/searchComponent/views/search_textfield_view.dart';
import 'package:flutter/material.dart';

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
  final List<SearchCategory> _selectedCategories = [SearchCategory.lectures, SearchCategory.rooms];
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    if (widget.index == 0) {
      _selectedCategories.add(SearchCategory.lectures);
      _selectedCategories.add(SearchCategory.grade);
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
            ? const Center(child: Text("Enter a Query to Start"))
            : (_selectedCategories.isEmpty)
                ? const Center(child: Text("Select some Categories to Start"))
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
            data: SearchCategory.values.where((element) => element != SearchCategory.unknown).toList(),
            height: 40,
            child: (searchCategory) => FilterChip.elevated(
                  label: Text(searchCategory.title),
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
      case SearchCategory.news:
        // TODO:
        return Container();
      //case SearchCategory.studyRoom:
      //  return const StudyRoomSearchResultView();
      case SearchCategory.lectures:
        return LectureSearchResultView(searchText: _searchText, key: const ValueKey("lectureSearchResultView"));
      case SearchCategory.rooms:
        return RoomSearchResultView(searchText: _searchText, key: const ValueKey("roomsSearchResultView"));
      case SearchCategory.persons:
        // TODO:
        return Container();
      default:
        return Container();
    }
  }
}


enum SearchCategory {
  /// enums that exist in the Text Classification Model
  cafeterias("Cafeterias"),
  calendar("Calendar"),
  grade("Grades"),
  movie("Movies"),
  news("News"),
  studyRoom("Study Rooms"),
  unknown("Unknown"),

  /// enums that are not classified but shown in searches
  lectures("Lectures"),
  rooms("Rooms"),
  persons("Persons");

  final String title;

  const SearchCategory(this.title);

  factory SearchCategory.fromString(String category) {
    switch (category) {
      case "cafeterias":
        return SearchCategory.cafeterias;
      case "calendar":
        return SearchCategory.calendar;
      case "grade":
        return SearchCategory.grade;
      case "movie":
        return SearchCategory.movie;
      case "news":
        return SearchCategory.news;
      case "studyroom":
        return SearchCategory.studyRoom;
      default:
        return SearchCategory.unknown;
    }
  }
}