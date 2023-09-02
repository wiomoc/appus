import 'package:campus_flutter/base/helpers/string_parser.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

enum VehicleType {
  ubahn,
  sbahn,
  regio,
  bus,
  onDemandCab,
  sev,
  unknown;

  static VehicleType fromVVSString(String? vvsString) {
    switch (vvsString) {
      case "U-Bahn":
        return VehicleType.ubahn;
      case "S-Bahn":
        return VehicleType.sbahn;
      case "R-Bahn":
        return VehicleType.regio;
      case "Bus":
        return VehicleType.bus;
      case "SEV-Bus":
        return VehicleType.sev;
      case "Ruftaxi":
        return VehicleType.onDemandCab;
      default:
        return VehicleType.unknown;
    }
  }

  Color get color {
    switch (this) {
      case VehicleType.ubahn:
        return const Color.fromARGB(255, 0x0b, 0xa1, 0xe2);
      case VehicleType.sbahn:
      case VehicleType.sev:
        return const Color.fromARGB(255, 0x53, 0xb3, 0x30);
      case VehicleType.regio:
        return const Color.fromARGB(255, 0x8F, 0x90, 0x8F);
      case VehicleType.bus:
        return const Color.fromARGB(255, 0xC3, 0x19, 0x24);
      case VehicleType.onDemandCab:
        return const Color.fromARGB(255, 0x18, 0x3F, 0x8A);
      default:
        return const Color.fromARGB(255, 0x8F, 0x90, 0x8F);
    }
  }
}

class Departure {
  final DateTime timePlanned;
  final DateTime? timeEstimated;
  final String number;
  final VehicleType vehicleType;
  final String destination;
  final String? platform;

  Departure(
      {required this.timePlanned,
      this.timeEstimated,
      required this.number,
      required this.vehicleType,
      required this.destination,
      this.platform});

  int? get delay {
    if (timeEstimated != null && timePlanned.isBefore(timeEstimated!)) {
      return timeEstimated!.difference(timePlanned).inMinutes;
    } else {
      return null;
    }
  }
}
