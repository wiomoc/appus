import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../model/meal.dart';
import 'meal_bottom_sheet.dart';
import 'stars_widget.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final DateTime date;
  final double? stars;
  final void Function(double?) onStarsUpdate;

  const MealCard({required this.meal, this.stars, required this.date, required this.onStarsUpdate, super.key});

  @override
  Widget build(BuildContext context) {
    final photoUrl = meal.photoUrl;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      child: InkWell(
          onTap: () {
            _showDetailsBottomSheet(context);
          },
          borderRadius: BorderRadius.circular(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (photoUrl != null)
                ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: CachedNetworkImage(
                      imageUrl: photoUrl,
                      fit: BoxFit.fitWidth,
                      progressIndicatorBuilder: (context, url, loadingProgress) {
                        return const Center(
                            child: Padding(padding: EdgeInsets.all(25), child: CircularProgressIndicator()));
                      },
                    )),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(meal.category, style: Theme.of(context).textTheme.titleLarge),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 1)),
                          Expanded(
                              child: Text(
                                meal.name,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              )),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${meal.price} €", maxLines: 1, style: Theme.of(context).textTheme.bodyLarge),
                                starsButton(context, stars),
                              ])
                        ])),
              )
            ],
          )),
    );
  }

  void _showDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: true,
        context: context,
        builder: (context) => MealBottomSheet(meal: meal, stars: stars, date: date, onStarsUpdate: onStarsUpdate));
  }
}