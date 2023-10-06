import 'package:campus_flutter/calendarComponent/model/calendar_event.dart';
import 'package:campus_flutter/gradeComponent/viewModels/grade_viewmodel.dart';
import 'package:campus_flutter/loginComponent/viewModels/login_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// get_it instance for singleton services
final getIt = GetIt.instance;

/// state providers for user interaction
final selectedEvent = StateProvider<CalendarEvent?>((ref) => null);
final useWebView = StateProvider<bool>((ref) => true);
final hideFailedGrades = StateProvider<bool>((ref) => false);

/// viewModels for RiverPod - state is uninitialized at first
/// view model for authentication handling
final loginViewModel = Provider((ref) => LoginViewModel());


/// view model for grades
final gradeViewModel = Provider((ref) => GradeViewModel(ref));

