import 'package:campus_flutter/calendarComponent/model/calendar_event.dart';
import 'package:campus_flutter/calendarComponent/viewModels/calendar_viewmodel.dart';
import 'package:campus_flutter/departuresComponent/viewModel/departures_viewmodel.dart';
import 'package:campus_flutter/gradeComponent/viewModels/grade_viewmodel.dart';
import 'package:campus_flutter/homeComponent/split_view_viewmodel.dart';
import 'package:campus_flutter/loginComponent/viewModels/login_viewmodel.dart';
import 'package:campus_flutter/movieComponent/viewModel/movies_viewmodel.dart';
import 'package:campus_flutter/navigatumComponent/viewModels/navigatum_viewmodel.dart';
import 'package:campus_flutter/newsComponent/viewModel/news_viewmodel.dart';
import 'package:campus_flutter/personDetailedComponent/viewModel/person_details_viewmodel.dart';
import 'package:campus_flutter/placesComponent/viewModels/cafeterias_viewmodel.dart';
import 'package:campus_flutter/placesComponent/viewModels/places_viewmodel.dart';
import 'package:campus_flutter/placesComponent/viewModels/study_rooms_viewmodel.dart';
import 'package:campus_flutter/profileComponent/model/profile.dart';
import 'package:campus_flutter/profileComponent/viewModel/profile_viewmodel.dart';
import 'package:campus_flutter/searchComponent/viewmodels/search_viewmodel.dart';
import 'package:campus_flutter/searchComponent/viewmodels/searchableViewModels/cafeteria_search_viewmodel.dart';
import 'package:campus_flutter/searchComponent/viewmodels/searchableViewModels/calendar_search_viewmodel.dart';
import 'package:campus_flutter/searchComponent/viewmodels/searchableViewModels/grades_search_viewmodel.dart';
import 'package:campus_flutter/searchComponent/viewmodels/searchableViewModels/lecture_seach_viewmodel.dart';
import 'package:campus_flutter/searchComponent/viewmodels/searchableViewModels/movie_search_viewmodel.dart';
import 'package:campus_flutter/searchComponent/viewmodels/searchableViewModels/study_room_search_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// get_it instance for singleton services
final getIt = GetIt.instance;

/// state providers for user interaction
final selectedEvent = StateProvider<CalendarEvent?>((ref) => null);
final selectedProfile = StateProvider<Profile?>((ref) => null);
final useWebView = StateProvider<bool>((ref) => true);
final hideFailedGrades = StateProvider<bool>((ref) => false);

/// viewModels for RiverPod - state is uninitialized at first
/// view model for authentication handling
final loginViewModel = Provider((ref) => LoginViewModel());

/// view model for users profile
final profileViewModel = Provider.autoDispose((ref) {
  final profileViewModel = ProfileViewModel();
  profileViewModel.fetch(false);
  ref.keepAlive();
  return profileViewModel;
});

/// view model for users details and person details
final profileDetailsViewModel = Provider.autoDispose((ref) {
  final profile = ref.watch(profileViewModel).profile.value;
  final profileDetailsViewModel = PersonDetailsViewModel(profile);
  profileDetailsViewModel.fetch(false);
  ref.keepAlive();
  return profileDetailsViewModel;
});
final personDetailsViewModel = Provider((ref) {
  final profile = ref.watch(selectedProfile);
  return PersonDetailsViewModel(profile);
});

/// view model for places
final placesViewModel = Provider((ref) => PlacesViewModel());
final navigaTumViewModel = Provider((ref) => NavigaTumViewModel());
//final cafeteriaWidgetViewModel = Provider((ref) => CafeteriaWidgetViewModel());
//final studyRoomWidgetViewModel = Provider((ref) => StudyRoomWidgetViewModel());
final cafeteriasViewModel = Provider((ref) => CafeteriasViewModel());
final studyRoomsViewModel = Provider((ref) => StudyRoomsViewModel());

/// view model for news
final newsViewModel = Provider((ref) => NewsViewModel());

/// view model for movies
final movieViewModel = Provider((ref) => MovieViewModel());

/// view model for grades
final gradeViewModel = Provider((ref) => GradeViewModel(ref));

/// view model for calendar
final calendarViewModel = Provider((ref) => CalendarViewModel());

/// view model for departures
final departureViewModel = Provider((ref) => DeparturesViewModel());

/// view model for landscape mode
final homeSplitViewModel = Provider((ref) => SplitViewViewModel());

/// view model for landscape mode of lectures
final lectureSplitViewModel = Provider((ref) => SplitViewViewModel());

/// search view models
final searchViewModel = Provider((ref) => SearchViewModel(ref));
final gradesSearchViewModel = Provider((ref) => GradesSearchViewModel());
final cafeteriaSearchViewModel = Provider((ref) => CafeteriaSearchViewModel());
final movieSearchViewModel = Provider((ref) => MovieSearchViewModel());
final calendarSearchViewModel = Provider((ref) => CalendarSearchViewModel());
final studyRoomSearchViewModel = Provider((ref) => StudyRoomSearchViewModel());
