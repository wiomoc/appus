import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget starsButton(BuildContext context, double? stars) {
  return OutlinedButton(onPressed: () {}, child: starsWithLabel(context, stars));
}

Widget starsWithLabel(BuildContext context, double? stars) {
  final color = Theme.of(context).colorScheme.primary;

  if (stars == null) {
    return Icon(Icons.star_half_outlined, color: color);
  }
  late IconData icon;
  if (stars < 2.3) {
    icon = Icons.star_border;
  } else if (stars < 3.6) {
    icon = Icons.star_half_outlined;
  } else {
    icon = Icons.star;
  }

  return Row(children: [
    Icon(icon, color: color),
    Text(
      NumberFormat.decimalPatternDigits(decimalDigits: 1).format(stars),
      style: TextStyle(color: color),
    )
  ]);
}