import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:campus_flutter/base/helpers/card_with_padding.dart';
import 'package:campus_flutter/base/helpers/retryable.dart';
import 'package:campus_flutter/base/views/generic_stream_builder.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../base/helpers/delayed_loading_indicator.dart';
import '../../../base/networking/apis/appusBackendApi/appus_backend_api.dart';
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

Widget _ratingButton(BuildContext context, double? stars) {
  return OutlinedButton(onPressed: () {}, child: _starWithLabel(context, stars));
}

Widget _starWithLabel(BuildContext context, double? stars) {
  final color = Theme
      .of(context)
      .colorScheme
      .primary;

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

class MealCardSliverBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget Function(BuildContext context) builder;
  final double extent;

  MealCardSliverBarDelegate({required this.builder, this.extent = 80});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(fit: StackFit.loose, children: [
      Container(
        color: Theme
            .of(context)
            .colorScheme
            .background,
      ),
      builder(context),
    ]);
  }

  @override
  double get maxExtent => extent;

  @override
  double get minExtent => extent;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

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
                          Text(meal.category, style: Theme
                              .of(context)
                              .textTheme
                              .titleLarge),
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
                                Text("${meal.price} €", maxLines: 1, style: Theme
                                    .of(context)
                                    .textTheme
                                    .bodyLarge),
                                _ratingButton(context, stars),
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

class MealBottomSheet extends StatefulWidget {
  final Meal meal;
  final double? stars;
  final DateTime date;
  final void Function(double?) onStarsUpdate;

  const MealBottomSheet({super.key, required this.meal, this.stars, required this.date, required this.onStarsUpdate});

  @override
  State<StatefulWidget> createState() {
    return _MealBottomSheetState();
  }
}

class _MealBottomSheetState extends State<MealBottomSheet> {
  double? _stars;
  AsyncSnapshot<Rating> _ratingsSnapshot = const AsyncSnapshot.waiting();
  late Retryable<Rating> _ratingsRetryable;
  late bool _allowRating = false;

  @override
  void initState() {
    _stars = widget.stars;
    _ratingsRetryable = Retryable(() => fetchRatingDetails(widget.meal.name));
    _ratingsRetryable.stream.listen((snapshot) {
      setState(() {
        _ratingsSnapshot = AsyncSnapshot.withData(ConnectionState.done, snapshot);
        if (_stars != snapshot.stars) {
          _stars = snapshot.stars;
          widget.onStarsUpdate(snapshot.stars);
        }
      });
    }, onError: (error) {
      setState(() {
        _ratingsSnapshot = AsyncSnapshot.withError(ConnectionState.done, error);
      });
    });
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final isToday = today == widget.date;
    if (isToday) {
      hasAlreadyRated(widget.meal.name, today).then((hasAlreadyRated) {
        if (!hasAlreadyRated) {
          setState(() {
            _allowRating = true;
          });
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final photoUrl = meal.photoUrl;
    late final Widget ratingsWidget;
    if (_ratingsSnapshot.hasData) {
      final comments = _ratingsSnapshot.data!.comments;
      if (comments.isEmpty) {
        ratingsWidget = SliverList.list(children: [
          Align(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 25),
                  child: Text(
                    "No ratings yet",
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyLarge,
                  )))
        ]);
      } else {
        ratingsWidget = SliverList.separated(
            itemCount: comments.length,
            itemBuilder: (context, index) => _submittedRatingTile(comments[index]),
            separatorBuilder: (context, index) =>
            const Divider(
              indent: 5,
              endIndent: 5,
            ));
      }
    } else if (_ratingsSnapshot.hasError) {
      ratingsWidget = SliverList.list(children: [
        Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Text(
                "Could not load Ratings",
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyLarge,
              ),
              const Padding(padding: EdgeInsets.all(5)),
              ElevatedButton(onPressed: () => _ratingsRetryable.retry(), child: const Text("Retry")),
            ]))
      ]);
    } else {
      ratingsWidget = SliverList.list(children: [const DelayedLoadingIndicator(name: "Ratings")]);
    }

    return DraggableScrollableSheet(
        initialChildSize: photoUrl == null ? 0.3 : 0.6,
        minChildSize: 0.3,
        maxChildSize: 1,
        expand: false,
        builder: (context, scrollController) {
          return CustomScrollView(controller: scrollController, slivers: [
            SliverList.list(children: [
              if (photoUrl == null)
                const Padding(padding: EdgeInsets.symmetric(vertical: 10))
              else
                ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: CachedNetworkImage(
                      imageUrl: photoUrl,
                      fit: BoxFit.fitWidth,
                      progressIndicatorBuilder: (context, url, loadingProgress) {
                        return const Center(
                            child: Padding(padding: EdgeInsets.all(25), child: CircularProgressIndicator()));
                      },
                    )),
            ]),
            _headerBar(),
            SliverList.list(children: [
              if (meal.additives.isNotEmpty)
                SizedBox(
                    height: 60,
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: meal.additives.reversed
                            .map((additive) => additives[additive])
                            .whereNotNull()
                            .map((additive) =>
                            Padding(
                                padding: const EdgeInsets.all(4),
                                child: Chip(
                                    avatar: (additive.icon != null)
                                        ? Icon(
                                      additive.icon,
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    )
                                        : null,
                                    label: Text(additive.germanName))))
                            .toList())),
              if (_allowRating) ...[
                MealRatingTile(
                  meal: meal,
                  onRatingSubmitted: (newAverageStars) {
                    setRated(meal.name, widget.date);
                    setState(() {
                      _allowRating = false;
                      _stars = newAverageStars;
                      widget.onStarsUpdate(newAverageStars);
                    });
                    _ratingsRetryable.retry();
                  },
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              ] else
                const Divider()
            ]),
            ratingsWidget
          ]);
        });
  }

  SliverPersistentHeader _headerBar() {
    final meal = widget.meal;
    return SliverPersistentHeader(
        pinned: true,
        floating: true,
        delegate: MealCardSliverBarDelegate(
            extent: ((meal.meal.length + (meal.description?.length ?? 0)) < 40) ? 65 : 80,
            builder: (context) =>
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(meal.category, style: Theme
                                  .of(context)
                                  .textTheme
                                  .titleMedium),
                              Text(meal.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .bodyMedium)
                            ])),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: Text("${meal.price}€",
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(color: Theme
                                    .of(context)
                                    .textTheme
                                    .titleLarge!
                                    .color))),
                        if (_stars != null) _ratingButton(context, _stars),
                      ]))
                ])));
  }

  Widget _submittedRatingTile(RatingComment ratingComment) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Container(
                      constraints: (ratingComment.imageUrl != null) ? const BoxConstraints(minHeight: 120) : null,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (ratingComment.comment != null)
                              Padding(padding: const EdgeInsets.only(bottom: 3), child: Text(ratingComment.comment!)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _starWithLabel(context, ratingComment.stars),
                                Text(timeago.format(ratingComment.date))
                              ],
                            )
                          ]))),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
              if (ratingComment.imageUrl != null)
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      Dialog(
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                "$appusBackendBaseUrl${ratingComment.imageUrl!}",
                                              ))));
                            },
                            child: CachedNetworkImage(
                              imageUrl: "$appusBackendBaseUrl${ratingComment.thumbImageUrl!}",
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorWidget: (context, error, stackTrace) => Container(),
                            )))),
            ]));
  }
}

class MealRatingTile extends StatefulWidget {
  final Meal meal;
  final void Function(double newAverageStars) onRatingSubmitted;

  const MealRatingTile({super.key, required this.meal, required this.onRatingSubmitted});

  @override
  State<StatefulWidget> createState() {
    return _MealRatingTileState();
  }
}

class _MealRatingTileState extends State<MealRatingTile> {
  Uint8List? _selectedImage;
  double rating = 0;
  late TextEditingController _commentController;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  Future<void> _sendRating() async {
    setState(() {
      _sending = true;
    });

    try {
      final newAverageStars = await sendRating(
          mealName: widget.meal.name, stars: rating, comment: _commentController.text, image: _selectedImage);
      widget.onRatingSubmitted(newAverageStars);
    } finally {
      setState(() {
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primary = Theme
        .of(context)
        .colorScheme
        .primary;
    return CardWithPadding(
        margin: const EdgeInsets.all(5),
        child: Column(children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: RatingBar(
                      initialRating: rating,
                      minRating: 1,
                      maxRating: 5,
                      glow: false,
                      allowHalfRating: true,
                      ratingWidget: RatingWidget(
                        full: Icon(Icons.star, color: primary),
                        half: Icon(Icons.star_half_outlined, color: primary),
                        empty: Icon(Icons.star_border, color: primary.withOpacity(0.7)),
                      ),
                      onRatingUpdate: (value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    )),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.send,
                    size: 25,
                  ),
                  onPressed: rating != 0 && !_sending
                      ? () {
                    _sendRating();
                  }
                      : null,
                  label: const Text("Bewerten"),
                )
              ]),
          const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
          TextField(
            controller: _commentController,
            enabled: !_sending,
            minLines: 1,
            maxLines: 10,
            //scrollPadding: EdgeInsets.only(bottom:850),

            decoration: InputDecoration(
              //fillColor: Theme.of(context).colorScheme.onPrimaryContainer,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              //filled: true,
              suffixIcon: IconButton(
                onPressed: () {
                  if (_selectedImage != null) {
                    setState(() {
                      _selectedImage = null;
                    });
                  } else {
                    ImagePicker()
                        .pickImage(source: ImageSource.camera)
                        .then((file) => file?.readAsBytes() ?? Future.value())
                        .then((value) =>
                        setState(() {
                          _selectedImage = value;
                        }));
                  }
                },
                icon: _selectedImage != null
                    ? SizedBox(
                    width: 55,
                    height: 55,
                    child: Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.memory(
                              _selectedImage!,
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              color: Colors.black12,
                              colorBlendMode: BlendMode.darken,
                            )),
                        const Center(
                            child: Icon(
                              Icons.cancel_outlined,
                              size: 30,
                              color: Colors.white,
                            )),
                      ],
                    ))
                    : const SizedBox(height: 55, child: Icon(Icons.add_a_photo)),
              ),
              labelText: 'Comment',
            ),
          ),
          //Divider(),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
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
              .map((location) =>
              DropdownMenuItem(
                value: location,
                child: Text(location.name, style: const TextStyle(fontSize: 18)),
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
          errorBuilder: (context, error) =>
              ErrorHandlingView(
                error: error,
                errorHandlingViewType: ErrorHandlingViewType.fullScreen,
                retry: (force) {
                  _mealsRetryable.retry();
                },
              ),
          loadingBuilder: (context) => const DelayedLoadingIndicator(name: "Meals")),
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
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
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
                _tabController.animateTo(meals.keys.indexed
                    .where((element) => element.$2 == dateRange.value)
                    .first
                    .$1);
                _fetchRatingSummary();
              },
            )),
        Expanded(
            child: TabBarView(
                controller: _tabController,
                children: meals.entries
                    .map((dayMeals) =>
                    GridView.builder(
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
