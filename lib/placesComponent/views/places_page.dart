import 'package:campus_flutter/base/enums/campus.dart';
import 'package:campus_flutter/base/helpers/icon_text.dart';
import 'package:campus_flutter/base/helpers/padded_divider.dart';
import 'package:campus_flutter/theme.dart';
import 'package:flutter/material.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

import '../../departuresComponent/views/departures_details_view.dart';
import '../../learningSpacesComponent/views/learning_spaces_page.dart';
import '../../mensaComponent/views/mensas_page.dart';
import 'campuses/campus_card_view.dart';

class PlacesPage extends StatelessWidget {
  const PlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        _navigationCard(context, Icons.school, AppLocalizations.of(context)!.placesLearningSpaces,
            (context) => const LearningSpacesPage()),
        _navigationCard(
            context, Icons.restaurant, AppLocalizations.of(context)!.placesMensa, (context) => const MensasPage()),
        _navigationCard(context, Icons.train, AppLocalizations.of(context)!.placesPublicTransport,
            (context) => const DeparturesPage()),
        const PaddedDivider(),
        if (MediaQuery.of(context).size.width < 700) ...[
          const CampusCardView(campus: Campus.vaihingen),
          const CampusCardView(campus: Campus.stadtmitte)
        ]
        else
          const Row(children: [
            Expanded(child: CampusCardView(campus: Campus.vaihingen)),
            Expanded(child: CampusCardView(campus: Campus.stadtmitte))
          ],)
        //for (var campus in ref.watch(placesViewModel).campuses) CampusCardView(campus: campus),
      ],
    ));
  }

  Widget _navigationCard(BuildContext context, IconData icon, String label, WidgetBuilder routeBuilder) {
    return SizedBox(
        height: 60,
        width: double.infinity,
        child: Card(
            margin: EdgeInsets.all(context.halfPadding),
            child: InkWell(
                borderRadius: BorderRadius.circular(10.0),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        IconText(iconData: icon, label: label, iconSize: 24),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, size: 15)
                      ],
                    )),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: routeBuilder)))));
  }
}
