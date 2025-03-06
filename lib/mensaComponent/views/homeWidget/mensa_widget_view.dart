import 'package:cached_network_image/cached_network_image.dart';
import 'package:campus_flutter/base/extensions/date_day.dart';
import 'package:campus_flutter/base/helpers/api_backed_state.dart';
import 'package:campus_flutter/base/helpers/horizontal_slider.dart';
import 'package:campus_flutter/base/views/error_handling_view.dart';
import 'package:campus_flutter/homeComponent/widgetComponent/views/widget_frame_view.dart';
import 'package:campus_flutter/theme.dart';
import 'package:flutter/material.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

import '../../api/sws_meals.dart';
import '../../mensa_service.dart';
import '../../model/meal.dart';
import '../meal_bottom_sheet.dart';

class MensaWidgetView extends StatefulWidget {
  const MensaWidgetView({super.key});

  @override
  State<StatefulWidget> createState() => _MensaWidgetViewState();
}

class _MensaWidgetViewState extends ApiBackedState<Map<DateTime, List<Meal>>, MensaWidgetView> {
  MensaLocation? _location;

  @override
  void initState() {
    super.initState();
    getLastMensaLocation().then((value) => setState(() {
          _location = value;
          load(MealsApiOperation(value.id), const Duration(minutes: 15));
        }));
  }

  @override
  Widget build(BuildContext context) => WidgetFrameView(title: _location?.name ?? "Mensa", child: body());

  @override
  Widget? buildBody(Map<DateTime, List<Meal>> data) {
    final DateTime today = DateTime.now().dateDay;
    final todaysMeals = data[today];
    final todaysMainMeals = todaysMeals?.where((meal) => meal.category.contains("Tagesangebot")).toList();
    if (todaysMainMeals != null && todaysMainMeals.isNotEmpty) {
      return HorizontalSlider<Meal>(
          data: todaysMainMeals,
          height: 190,
          leadingTrailingPadding: context.halfPadding,
          child: (meal) {
            return SizedBox(
                width: 160,
                height: 180,
                child: SimpleMealCard(
                  meal: meal,
                ));
          });
    } else {
      return Card(
          child: SizedBox(height: 190, child: Center(child: Text(AppLocalizations.of(context)!.mensaMealsEmpty))));
    }
  }

  @override
  String get resourceName => AppLocalizations.of(context)!.mensaMeals;

  @override
  ErrorHandlingViewType get errorHandlingViewType => ErrorHandlingViewType.descriptionOnly;
}

class SimpleMealCard extends StatelessWidget {
  final Meal meal;

  const SimpleMealCard({super.key, required this.meal});

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
            mainAxisSize: MainAxisSize.min,
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
                        Expanded(
                            child: Text(
                          meal.name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        )),
                        Text("${meal.price} €", maxLines: 1, style: Theme.of(context).textTheme.bodyLarge),
                      ]),
                ),
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
        builder: (context) => MealBottomSheet(meal: meal, date: DateTime.now().dateDay));
  }
}
