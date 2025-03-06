import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
class LocationService {
  static Future<Position> determinePosition({bool askForPermission = true}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location Service disabled");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if(!askForPermission) {
        return Future.error("No Permission");
      }
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error("Permission forever denied");
      }

      if (permission == LocationPermission.denied) {
        return Future.error("Permission denied");
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  static Future<Position?> getLastKnown() async {
    if (kIsWeb) {
      return await determinePosition();
    } else {
      return await Geolocator.getLastKnownPosition();
    }
  }
}