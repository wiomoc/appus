import 'package:campus_flutter/base/helpers/card_with_padding.dart';
import 'package:campus_flutter/base/helpers/icon_text.dart';
import 'package:campus_flutter/base/helpers/padded_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../departuresComponent/views/departures_details_view.dart';
import '../../learningSpacesComponent/learning_spaces_page.dart';
import '../../mensaComponent/mensas_view.dart';

class PlacesPage extends StatelessWidget {
  const PlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        InkWell(
            child: AspectRatio(
                aspectRatio: 6,
                child: CardWithPadding(
                    child: Row(
                  children: [
                    IconText(iconData: Icons.school, label: AppLocalizations.of(context)!.placesLearningSpaces, iconSize: 24),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 15)
                  ],
                ))),
            onTap: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LearningSpacesPage()))),
        InkWell(
            child: AspectRatio(
                aspectRatio: 6,
                child: CardWithPadding(
                    child: Row(
                  children: [
                    IconText(iconData: Icons.restaurant, label: AppLocalizations.of(context)!.placesMensa, iconSize: 24),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 15)
                  ],
                ))),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MensasPage()))),
        InkWell(
            child: AspectRatio(
                aspectRatio: 6,
                child: CardWithPadding(
                    child: Row(
                  children: [
                    IconText(iconData: Icons.train, label: AppLocalizations.of(context)!.placesPublicTransport, iconSize: 24),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 15)
                  ],
                ))),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DeparturesPage()))),
        const PaddedDivider(),
        //for (var campus in ref.watch(placesViewModel).campuses) CampusCardView(campus: campus),
      ],
    ));
  }
}
