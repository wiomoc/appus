import 'package:campus_flutter/base/networking/protocols/view_model.dart';
import 'package:campus_flutter/profileComponent/model/tuition.dart';
import 'package:rxdart/rxdart.dart';

import '../model/profile.dart';
import '../services/profile_service.dart';

class ProfileViewModel implements ViewModel {
  BehaviorSubject<Profile?> profile = BehaviorSubject.seeded(null);
  BehaviorSubject<Tuition?> tuition = BehaviorSubject.seeded(null);
  final BehaviorSubject<DateTime?> lastFetched = BehaviorSubject.seeded(null);

  @override
  Future fetch(bool forcedRefresh) async {
    /*ProfileService.fetchProfile(forcedRefresh).then((response) {
      lastFetched.add(response.$1);
      profile.add(response.$2);
      ProfileService.fetchTuition(forcedRefresh, response.$2.personGroup ?? "", response.$2.id ?? "")
          .then((response) => tuition.add(response.$2), onError: (error) => tuition.addError(error));
    }, onError: (error) => profile.addError(error));*/
  }
}