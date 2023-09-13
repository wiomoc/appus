import 'package:campus_flutter/calendarComponent/model/calendar_event.dart';
import 'package:campus_flutter/gradeComponent/viewModels/grade_viewmodel.dart';
import 'package:campus_flutter/homeComponent/split_view_viewmodel.dart';
import 'package:campus_flutter/loginComponent/viewModels/login_viewmodel.dart';
import 'package:campus_flutter/newsComponent/viewModel/news_viewmodel.dart';
import 'package:campus_flutter/personDetailedComponent/viewModel/person_details_viewmodel.dart';
import 'package:campus_flutter/placesComponent/viewModels/places_viewmodel.dart';
import 'package:campus_flutter/profileComponent/model/profile.dart';
import 'package:campus_flutter/profileComponent/viewModel/profile_viewmodel.dart';
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

/// view model for news
final newsViewModel = Provider((ref) => NewsViewModel());

/// view model for movies

/// view model for grades
final gradeViewModel = Provider((ref) => GradeViewModel(ref));

/// view model for landscape mode
final homeSplitViewModel = Provider((ref) => SplitViewViewModel());
