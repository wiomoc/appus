import 'package:campus_flutter/base/helpers/card_with_padding.dart';
import 'package:campus_flutter/base/helpers/icon_text.dart';
import 'package:campus_flutter/base/helpers/padded_divider.dart';
import 'package:campus_flutter/placesComponent/views/campuses/campus_card_view.dart';
import 'package:campus_flutter/placesComponent/views/mensa/mensas_view.dart';
import 'package:campus_flutter/providers_get_it.dart';
import 'package:campus_flutter/vvsComponent/views/departures_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'learningSpaces/learning_spaces_page.dart';

class PlacesView extends ConsumerWidget {
  const PlacesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
        child: Column(
      children: [
        InkWell(
            child: const AspectRatio(
                aspectRatio: 6,
                child: CardWithPadding(
                    child: Row(
                  children: [
                    IconText(iconData: Icons.school, label: "Learning Spaces", iconSize: 24),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, size: 15)
                  ],
                ))),
            onTap: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LearningSpacesPage()))),
        InkWell(
            child: const AspectRatio(
                aspectRatio: 6,
                child: CardWithPadding(
                    child: Row(
                  children: [
                    IconText(iconData: Icons.restaurant, label: "Cafeterias", iconSize: 24),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, size: 15)
                  ],
                ))),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MensasPage()))),
        InkWell(
            child: const AspectRatio(
                aspectRatio: 6,
                child: CardWithPadding(
                    child: Row(
                  children: [
                    IconText(iconData: Icons.train, label: "ÖPNV", iconSize: 24),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, size: 15)
                  ],
                ))),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DeparturesPage()))),
        const PaddedDivider(),
        for (var campus in ref.watch(placesViewModel).campuses) CampusCardView(campus: campus),
      ],
    ));
  }
}
