import 'package:campus_flutter/base/helpers/delayed_loading_indicator.dart';
import 'package:campus_flutter/base/helpers/icon_text.dart';
import 'package:campus_flutter/base/views/error_handling_view.dart';
import 'package:campus_flutter/providers_get_it.dart';
import 'package:flutter/material.dart';

import '../../base/helpers/retryable.dart';
import '../../base/views/generic_stream_builder.dart';
import '../model/departure.dart';
import '../services/departures_service.dart';
import 'departures_details_row_view.dart';

class Station {
  final String id;
  final String name;

  const Station(this.id, this.name);
}

const stations = [
  Station("de:08111:6008", "Universität"),
  Station("de:08111:6021", "Universität (Schleife)"),
  Station("de:08111:2603", "Schrane"),
];

class VVSPageView extends StatefulWidget {
  const VVSPageView({super.key});

  @override
  VVSPageState createState() {
    return VVSPageState();
  }
}

class VVSPageState extends State<VVSPageView> {
  Station _currentStation = stations.first;
  late Retryable<List<Departure>> _departuresRetryable;

  @override
  void initState() {
    super.initState();
    _departuresRetryable = Retryable(() => DeparturesService.fetchDepartures(_currentStation));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: DropdownButton(
          value: _currentStation,
          items: stations
              .map((location) => DropdownMenuItem(
                    value: location,
                    child: Text(location.name, style: TextStyle(fontSize: 18)),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              if (_currentStation != value) {
                _currentStation = value!;
                _departuresRetryable.retry();
              }
            });
          },
        ),
      ),
      body: GenericStreamBuilder(
          stream: _departuresRetryable.stream,
          dataBuilder: (context, departures) {
            return DeparturesDetailsView(
              key: ValueKey(_currentStation),
              departures: departures,
              station: _currentStation,
            );
          },
          errorBuilder: (context, error) => ErrorHandlingView(
                error: error,
                errorHandlingViewType: ErrorHandlingViewType.fullScreen,
                retry: (force) {
                  _departuresRetryable.retry();
                },
              ),
          loadingBuilder: (p0) => const DelayedLoadingIndicator(name: "Departures")),
    );
  }
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
            const Row(
              children: [
                SizedBox(width: 50, child: Text("Line", style: TextStyle(fontWeight: FontWeight.w500))),
                Padding(padding: EdgeInsets.symmetric(horizontal: 7.5)),
                Text("Direction", style: TextStyle(fontWeight: FontWeight.w500)),
                Spacer(),
                Text("Departure", style: TextStyle(fontWeight: FontWeight.w500))
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