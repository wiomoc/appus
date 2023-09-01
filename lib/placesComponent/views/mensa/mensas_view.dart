import 'package:campus_flutter/base/helpers/retryable.dart';
import 'package:campus_flutter/base/views/generic_stream_builder.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../base/helpers/card_with_padding.dart';
import '../../../base/helpers/delayed_loading_indicator.dart';
import '../../../base/views/error_handling_view.dart';
import '../../viewModels/cafeterias_viewmodel.dart';
import 'meal_model.dart';
import 'mensa_service.dart';

class MensaLocation {
  final String id;
  final String name;

  const MensaLocation(this.id, this.name);
}

const mensaLocations = [
  MensaLocation("mensa_stuttgart-vaihingen", "Mensa Stuttgart Vaihingen"),
  MensaLocation("mensa_central", "Mensa Central"),
];

class MealCard extends StatelessWidget {
  final Meal meal;

  const MealCard(this.meal, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (meal.photoPath != "")
            ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  "https://sws2.maxmanager.xyz/assets/${meal.photoPath!}",
                  fit: BoxFit.fitWidth,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                        child: Padding(padding: EdgeInsets.all(25), child: CircularProgressIndicator()));
                  },
                )),
          Padding(
            padding: EdgeInsets.all(5),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(meal.category, style: Theme.of(context).textTheme.titleLarge),
              const Padding(padding: EdgeInsets.symmetric(vertical: 1)),
              Text(
                ((meal.description != "") ? "${meal.meal}\n${meal.description}" : meal.meal) + "\n\n",
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 1)),
              Text("${meal.price} €", maxLines: 1, style: Theme.of(context).textTheme.bodyLarge),
            ]),
          )
        ],
      ),
    );
  }
}

class MensaPageView extends StatefulWidget {
  const MensaPageView({super.key});

  @override
  MensaPageState createState() {
    return MensaPageState();
  }
}

class MensaPageState extends State<MensaPageView> {
  MensaLocation currentLocation = mensaLocations.first;
  DateTime? selectedDate;
  late Retryable<Map<DateTime, List<Meal>>> _mealsRetryable;

  @override
  void initState() {
    super.initState();
    _mealsRetryable = Retryable(() => fetchMeals(currentLocation.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: DropdownButton(
          value: currentLocation,
          items: mensaLocations
              .map((location) => DropdownMenuItem(
                    value: location,
                    child: Text(location.name, style: TextStyle(fontSize: 18)),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              if (currentLocation != value) {
                currentLocation = value!;
                _mealsRetryable.retry();
              }
            });
          },
        ),
      ),
      body: GenericStreamBuilder(
          stream: _mealsRetryable.stream,
          dataBuilder: (context, meals) {
            final minDate = meals.keys.min;
            final maxDate = meals.keys.max;

            if (selectedDate == null || !meals.containsKey(selectedDate)) {
              //setState(() {
              selectedDate = minDate;
              // });
            }
            final todaysMeals = meals[selectedDate]!;
            return Column(
              children: [
                SizedBox(
                    height: 80,
                    child: SfDateRangePicker(
                      headerHeight: 0,
                      toggleDaySelection: false,
                      enablePastDates: false,
                      allowViewNavigation: false,
                      initialSelectedDate: selectedDate,
                      selectableDayPredicate: (date) => meals.containsKey(date),
                      minDate: minDate,
                      maxDate: maxDate,
                      monthViewSettings:
                          const DateRangePickerMonthViewSettings(numberOfWeeksInView: 1, firstDayOfWeek: 1),
                      onSelectionChanged: (args) => setState(() {
                        selectedDate = args.value as DateTime;
                      }),
                    )),
                Expanded(
                    child: GridView.builder(
                  padding: EdgeInsets.all(5),
                  itemCount: todaysMeals.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 235,
                  ),
                  itemBuilder: (context, index) => MealCard(todaysMeals[index]),
                ))

                //Text(dishes.first.$1.name)
              ],
            );
          },
          errorBuilder: (context, error) => ErrorHandlingView(
                error: error,
                errorHandlingViewType: ErrorHandlingViewType.fullScreen,
                retry: (force) {
                  _mealsRetryable.retry();
                },
              ),
          loadingBuilder: (p0) => const DelayedLoadingIndicator(name: "Meals")),
    );
  }
}
