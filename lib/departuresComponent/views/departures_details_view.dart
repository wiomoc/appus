import 'package:campus_flutter/base/helpers/api_backed_state.dart';
import 'package:campus_flutter/base/helpers/icon_text.dart';
import 'package:flutter/material.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

import '../api/vvs_departures.dart';
import '../departures_service.dart';
import '../model/departure.dart';
import 'departures_details_row_view.dart';

class DeparturesPage extends StatefulWidget {
  const DeparturesPage({super.key});

  @override
  State<DeparturesPage> createState() {
    return _DeparturesPageState();
  }
}

class _DeparturesPageState extends ApiBackedState<List<Departure>, DeparturesPage>
    with ApiPullRefresh, ApiBackedPageState {
  Station _currentStation = stations.first;

  @override
  void initState() {
    super.initState();
    getLastStation().then((value) => setState(() {
          load(DeparturesApiOperation(_currentStation));
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        bottom: bottomLoadingIndicator(),
        title: DropdownButton(
          value: _currentStation,
          items: stations
              .map((location) => DropdownMenuItem<Station>(
                    value: location,
                    child: Text(location.name, style: const TextStyle(fontSize: 18)),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              if (_currentStation != value) {
                _currentStation = value!;
                load(DeparturesApiOperation(value));
                setLastStation(value);
              }
            });
          },
        ),
      ),
      body: body(),
    );
  }

  @override
  Widget buildBody(List<Departure> departures) {
    return DeparturesDetailsView(
      key: ValueKey(_currentStation),
      departures: departures,
      station: _currentStation,
    );
  }

  @override
  String get resourceName => AppLocalizations.of(context)!.departures;
}

class DeparturesDetailsView extends StatelessWidget {
  const DeparturesDetailsView({super.key, required this.departures, required this.station});

  final Station station;
  final List<Departure> departures;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(TextSpan(text: "Station: ", children: [
              TextSpan(
                  text: station.name,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor))
            ])),
            GestureDetector(
                onTap: () async {
                  /*if (selectedStation.location != null) {
                        if (await MapLauncher.isMapAvailable(MapType.google) ?? false) {
                          await MapLauncher.showDirections(
                            mapType: MapType.google,
                            directionsMode: DirectionsMode.walking,
                            destinationTitle: selectedStation.name,
                            destination:
                                Coords(selectedStation.location!.latitude, selectedStation.location!.longitude),
                          );
                        } else if (await MapLauncher.isMapAvailable(MapType.apple) ?? false) {
                          await MapLauncher.showDirections(
                            mapType: MapType.apple,
                            directionsMode: DirectionsMode.walking,
                            destinationTitle: selectedStation.name,
                            destination:
                                Coords(selectedStation.location!.latitude, selectedStation.location!.longitude),
                          );
                        }
                      }*/
                },
                child: const IconText(iconData: Icons.open_in_new, label: "Show Directions")),
            const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
            Row(
              children: [
                SizedBox(width: 50, child: Text(AppLocalizations.of(context)!.departuresLine, style: const TextStyle(fontWeight: FontWeight.w500))),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 7.5)),
                Text(AppLocalizations.of(context)!.departuresDirection, style: const TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(AppLocalizations.of(context)!.departuresDeparture, style: const TextStyle(fontWeight: FontWeight.w500))
              ],
            ),
            const Divider(),
            Expanded(
                child: RefreshIndicator(
                    onRefresh: () {
                      //return ref.read(departureViewModel).fetch(true);
                      return Future.value();
                    },
                    child: ListView.separated(
                        itemBuilder: (context, index) => DeparturesDetailsRowView(departure: departures[index]),
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: departures.length))),
          ],
        ));
  }
}
