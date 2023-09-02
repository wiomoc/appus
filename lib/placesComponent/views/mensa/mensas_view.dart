import 'package:campus_flutter/base/helpers/retryable.dart';
import 'package:campus_flutter/base/views/generic_stream_builder.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../base/helpers/delayed_loading_indicator.dart';
import '../../../base/views/error_handling_view.dart';
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
                        ((meal.description != "") ? "${meal.meal}\n${meal.description}" : meal.meal),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      )),
                      Text("${meal.price} €", maxLines: 1, style: Theme.of(context).textTheme.bodyLarge),
                    ])),
          )
        ],
      ),
    );
  }
}

class MensasPageView extends StatefulWidget {
  const MensasPageView({super.key});

  @override
  MensasPageState createState() {
    return MensasPageState();
  }
}

class MensasPageState extends State<MensasPageView> {
  MensaLocation _currentLocation = mensaLocations.first;
  late Retryable<Map<DateTime, List<Meal>>> _mealsRetryable;

  @override
  void initState() {
    super.initState();
    _mealsRetryable = Retryable(() => fetchMeals(_currentLocation.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: DropdownButton(
          value: _currentLocation,
          items: mensaLocations
              .map((location) => DropdownMenuItem(
                    value: location,
                    child: Text(location.name, style: TextStyle(fontSize: 18)),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              if (_currentLocation != value) {
                _currentLocation = value!;
                _mealsRetryable.retry();
              }
            });
          },
        ),
      ),
      body: GenericStreamBuilder(
          stream: _mealsRetryable.stream,
          dataBuilder: (context, meals) {
            return MensaView(key: ValueKey(_currentLocation), meals: meals);
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

class MensaView extends StatefulWidget {
  final Map<DateTime, List<Meal>> meals;

  const MensaView({super.key, required this.meals});

  @override
  MensaViewState createState() {
    return MensaViewState();
  }
}

class MensaViewState extends State<MensaView> with TickerProviderStateMixin {
  late TabController _tabController;
  late DateRangePickerController _datePickerController;

  @override
  void initState() {
    super.initState();
    final meals = widget.meals;
    _datePickerController = DateRangePickerController();
    final minDate = meals.keys.min;
    _datePickerController.selectedDate = minDate;

    _tabController = TabController(length: meals.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _datePickerController.selectedDate = meals.keys.elementAt(_tabController.index);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final meals = widget.meals;
    final minDate = meals.keys.min;
    final maxDate = meals.keys.max;
    return Column(
      children: [
        SizedBox(
            height: 80,
            child: SfDateRangePicker(
              headerHeight: 0,
              toggleDaySelection: false,
              enablePastDates: false,
              allowViewNavigation: false,
              controller: _datePickerController,
              selectableDayPredicate: (date) => meals.containsKey(date),
              minDate: minDate,
              maxDate: maxDate,
              monthViewSettings: const DateRangePickerMonthViewSettings(numberOfWeeksInView: 1, firstDayOfWeek: 1),
              onSelectionChanged: (dateRange) {
                _tabController.animateTo(meals.keys.indexed.where((element) => element.$2 == dateRange.value).first.$1);
              },
            )),
        Expanded(
            child: TabBarView(
                controller: _tabController,
                children: meals.values
                    .map((todaysMeals) => GridView.builder(
                          padding: EdgeInsets.all(5),
                          itemCount: todaysMeals.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 235,
                          ),
                          itemBuilder: (context, index) => MealCard(todaysMeals[index]),
                        ))
                    .toList()))

        //Text(dishes.first.$1.name)
      ],
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _datePickerController.dispose();
    _tabController.dispose();
  }
}
