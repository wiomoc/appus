import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'departure.g.dart';

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
      case "Stadtbahn":
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
        return const Color(0xff0ba1e2);
      case VehicleType.sbahn:
      case VehicleType.sev:
        return const Color(0xff53b330);
      case VehicleType.regio:
        return const Color(0xff8f908f);
      case VehicleType.bus:
        return const Color(0xffc31924);
      case VehicleType.onDemandCab:
        return const Color(0xff183f8a);
      default:
        return const Color(0xff8f908f);
    }
  }
}

@JsonSerializable()
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

  factory Departure.fromJson(Map<String, dynamic> json) => _$DepartureFromJson(json);

  Map<String, dynamic> toJson() => _$DepartureToJson(this);
}
