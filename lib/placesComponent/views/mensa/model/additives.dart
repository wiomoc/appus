import 'package:flutter/material.dart';

final class Additive {
  final String germanName;
  final String? englishName;
  final IconData? icon;

  const Additive(this.germanName, {this.englishName, this.icon});
}

const Map<String, Additive> additives = {
  "Ei": Additive("Ei", icon: Icons.egg_outlined),
  "En": Additive("Erdnuss"),
  "Fi": Additive("Fisch", icon: Icons.phishing_outlined),
  "GlW": Additive("Weizen"),
  "GlD": Additive("Dinkel"),
  "GlKW": Additive("Khorsan-Weizen"),
  "GlR": Additive("Roggen"),
  "GlG": Additive("Gerste"),
  "GlH": Additive("Hafer"),
  "Kr": Additive("Krebstiere (Krusten- und Schalentiere)"),
  "La": Additive("Milch und Laktose"),
  "Lu": Additive("Lupine"),
  "NuM": Additive("Mandeln"),
  "NuH": Additive("Haselnüsse"),
  "NuW": Additive("Walnüsse"),
  "NuC": Additive("Cashewnüsse"),
  "NuPe": Additive("Pecanüsse"),
  "NuPa": Additive("Paranüsse"),
  "NuPi": Additive("Pistazien"),
  "NuMa": Additive("Macadamianüsse"),
  "Se": Additive("Sesam"),
  "Sf": Additive("Senf"),
  "Sl": Additive("Sellerie"),
  "So": Additive("Soja"),
  "Sw": Additive("Schwefeloxid (\"SO2\") und Sulfite"),
  "Wt": Additive("Weichtiere"),
  "1": Additive("mit Konservierungsstoffen"),
  "2": Additive("mit Farbstoffen", icon: Icons.color_lens_outlined),
  "3": Additive("mit Antioxodationsmitteln"),
  "4": Additive("mit Geschmacksverstärkern"),
  "5": Additive("geschwefelt"),
  "6": Additive("gewachst"),
  "7": Additive("mit Phosphaten"),
  "8": Additive("mit Süßungsmitteln"),
  "9": Additive("enthält eine Phenylaninquelle"),
  "10": Additive("geschwärzt"),
  "11": Additive("mit Alkohol", icon: Icons.liquor_outlined),
  "VG": Additive("Vegan", icon: Icons.grass_outlined),
  "V": Additive("Vegetarisch"),
  "P": Additive("Preisrenner", icon: Icons.monetization_on_outlined),
  "VR": Additive("Veganerrenner", icon: Icons.monetization_on_outlined),
  "G": Additive("Geflügel", icon: Icons.flutter_dash),
  "RS": Additive("Rind/Schwein"),
  "R": Additive("Rind"),
  "S": Additive("Schwein", icon: Icons.savings_outlined),
  "F": Additive("Fitness", icon: Icons.fitness_center_outlined),
  "MSC": Additive("MSC-zertifizierter Fisch")
};