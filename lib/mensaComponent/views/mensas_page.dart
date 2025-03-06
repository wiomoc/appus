import 'package:campus_flutter/base/helpers/api_backed_state.dart';
import 'package:campus_flutter/mapComponent/views/building_location_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

import '../api/sws_meals.dart';
import '../model/meal.dart';
import '../mensa_service.dart';
import 'meal_card.dart';

class MensasPage extends StatefulWidget {
  const MensasPage({super.key});

  @override
  State<MensasPage> createState() {
    return _MensasPageState();
  }
}

class _MensasPageState extends ApiBackedState<Map<DateTime, List<Meal>>, MensasPage> with ApiBackedPageState {
  MensaLocation? _currentLocation;

  @override
  void initState() {
    super.initState();
    getLastMensaLocation().then((value) => setState(() {
          _currentLocation = value;
          load(MealsApiOperation(value.id), const Duration(minutes: 15));
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        bottom: bottomLoadingIndicator(),
        actions: [
          if (_currentLocation?.aref != null)
            IconButton(
              icon: const Icon(Icons.map_outlined),
              tooltip: 'Show on map',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BuildingLocationPage(aref: _currentLocation!.aref!),
                ));
              },
            ),
        ],
        title: DropdownButton(
          value: _currentLocation,
          items: mensaLocations
              .map((location) => DropdownMenuItem(
                    value: location,
                    child: Text(location.name, style: const TextStyle(fontSize: 18)),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              if (_currentLocation != value) {
                _currentLocation = value!;
                load(MealsApiOperation(value.id), const Duration(minutes: 15));
                setLastMensaLocation(value);
              }
            });
          },
        ),
      ),
      body: body(),
    );
  }

  @override
  Widget buildBody(Map<DateTime, List<Meal>> meals) => MensaView(key: ValueKey(_currentLocation), meals: meals);

  @override
  String get resourceName => AppLocalizations.of(context)!.mensaMeals;
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
  final Map<String, double?> _mealsStars = {};

  @override
  void initState() {
    super.initState();
    final meals = widget.meals;
    _datePickerController = DateRangePickerController();
    final minDate = meals.keys.min;
    _datePickerController.selectedDate = minDate;
    _fetchRatingSummary();
    _tabController = TabController(length: meals.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _datePickerController.selectedDate = meals.keys.elementAt(_tabController.index);
        _fetchRatingSummary();
      });
    });
  }

  Future<void> _fetchRatingSummary() async {
    final mealsToFetch = widget.meals[_datePickerController.selectedDate]!
        .map((meal) => meal.name)
        .where((mealName) => !_mealsStars.containsKey(mealName))
        .toList();
    if (mealsToFetch.isEmpty) return;
    for (final mealToFetch in mealsToFetch) {
      _mealsStars[mealToFetch] = null;
    }

    final newMealRatingSummaries = await fetchStars(mealsToFetch);
    setState(() {
      _mealsStars.addAll(newMealRatingSummaries);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth ~/ 200;
    final widthOverflow = screenWidth % 200;
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
                _fetchRatingSummary();
              },
            )),
        Expanded(
            child: TabBarView(
                controller: _tabController,
                children: meals.entries
                    .map((dayMeals) => GridView.builder(
                          padding: const EdgeInsets.all(5),
                          itemCount: dayMeals.value.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisExtent: 255 + widthOverflow / (crossAxisCount * 2),
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10),
                          itemBuilder: (context, index) {
                            final meal = dayMeals.value[index];
                            return MealCard(
                              meal: meal,
                              stars: _mealsStars[meal.name],
                              date: dayMeals.key,
                              onStarsUpdate: (stars) {
                                setState(() {
                                  _mealsStars[meal.name] = stars;
                                });
                              },
                            );
                          },
                        ))
                    .toList()))
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _datePickerController.dispose();
    _tabController.dispose();
  }
}
