import 'package:campus_flutter/base/extensions/date_day.dart';
import 'package:campus_flutter/base/helpers/api_backed_state.dart';
import 'package:campus_flutter/base/helpers/card_with_padding.dart';
import 'package:campus_flutter/base/helpers/delayed_loading_indicator.dart';
import 'package:campus_flutter/base/helpers/horizontal_slider.dart';
import 'package:campus_flutter/base/views/error_handling_view.dart';
import 'package:campus_flutter/homeComponent/widgetComponent/views/widget_frame_view.dart';
import 'package:campus_flutter/placesComponent/model/cafeterias/cafeteria.dart';
import 'package:campus_flutter/placesComponent/model/cafeterias/cafeteria_menu.dart';
import 'package:campus_flutter/placesComponent/model/cafeterias/dish.dart';
import 'package:flutter/material.dart';

import '../api/sws_meals.dart';
import '../mensa_service.dart';
import '../model/meal.dart';

class MensaWidgetView extends StatefulWidget {
  const MensaWidgetView({super.key});

  @override
  State<StatefulWidget> createState() => _MensaWidgetViewState();
}

class _MensaWidgetViewState extends ApiBackedState<Map<DateTime, List<Meal>>,MensaWidgetView> {
  MensaLocation? _location;

  @override
  void initState() {
    super.initState();
    getLastMensaLocation().then((value) => setState(() {
          _location = value;
          load(MealsApiOperation(value.id), const Duration(minutes: 15));
        }));
  }

  // TODO: make nice
  @override
  Widget build(BuildContext context) => WidgetFrameView(title: _location?.name ?? "Mensa", child: body());


  @override
  Widget? buildBody(Map<DateTime, List<Meal>> data) {
    final DateTime today = DateTime.now().dateDay;
    final todaysMeals = data[today];
    if (todaysMeals != null && todaysMeals.isNotEmpty) {
      return MealSlider(meals: todaysMeals);
    } else {
      return const Card(child: SizedBox(height: 150, child: Center(child: Text("no meal plan found"))));
    }
  }

  @override
  String get resourceName => "Mealplan";

  @override
  ErrorHandlingViewType get errorHandlingViewType => ErrorHandlingViewType.descriptionOnly;
}

class MealSlider extends StatelessWidget {
  const MealSlider({super.key, required this.meals, this.inverted = false});

  final List<Meal> meals;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    return HorizontalSlider<Meal>(
        data: meals,
        height: 160,
        leadingTrailingPadding: !inverted,
        child: (meal) {
          return MealCard(
            meal: meal,
            inverted: inverted,
          );
        });
  }
}

class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.meal, required this.inverted});

  final Meal meal;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    return CardWithPadding(
        color: inverted ? Theme.of(context).colorScheme.background : null,
        height: 150,
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(meal.category, style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _dishInfoAlert(meal, context),
                      icon: Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerRight,
                      highlightColor: Colors.transparent,
                    )
                  ],
                )),
                const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                Expanded(
                    flex: 3,
                    child: Text(
                      meal.name,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )),
                Expanded(
                    child: Text(
                  "${meal.price}€",
                  maxLines: 1,
                ))
              ],
            )));
  }

  _dishInfoAlert(Meal meal, BuildContext context) {
  /*  showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(dish.name),
            actionsAlignment: MainAxisAlignment.center,
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              for (var label in dish.labels) ...[Text(label)],
              Text(CafeteriasViewModel.formatPrice(dish))
            ]),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Okay"))],
          );
        });*/
  }
}
