import 'package:campus_flutter/base/helpers/api_backed_state.dart';
import 'package:campus_flutter/base/helpers/api_operation.dart';
import 'package:flutter/material.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

import '../api/stuvus_learning_spaces.dart';
import '../api/tik_occupations.dart';
import '../model/learning_spaces.dart';
import 'learning_spaces_view.dart';

class LearningSpacesPage extends StatefulWidget {
  const LearningSpacesPage({super.key});

  @override
  LearningSpacesPageState createState() {
    return LearningSpacesPageState();
  }
}

class LearningSpacesPageState extends ApiBackedState<(LearningSpaces?, Map<String, double>?), LearningSpacesPage>
    with ApiBackedPageState {
  @override
  void initState() {
    super.initState();
    load(MergedApiOperation(LearningSpacesApiOperation(), TikOccupationsApiOperation()), const Duration(minutes: 15));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar(), body: body());
  }

  @override
  Widget? buildBody((LearningSpaces?, Map<String, double>?) data) {
    final learningSpaces = data.$1;
    if (learningSpaces == null) return null;
    return LearningSpacesView(learningSpaces: learningSpaces, occupations: data.$2);
  }

  @override
  String get resourceName => AppLocalizations.of(context)!.placesLearningSpaces;
}
