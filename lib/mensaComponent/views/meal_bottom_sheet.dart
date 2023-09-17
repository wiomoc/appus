import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../base/helpers/delayed_loading_indicator.dart';
import '../../../../base/helpers/retryable.dart';
import '../../../../base/networking/apis/appusBackendApi/appus_backend_api.dart';
import '../mensa_service.dart';
import '../model/additives.dart';
import '../model/meal.dart';
import '../model/rating.dart';
import 'meal_rating_tile.dart';
import 'stars_widget.dart';

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
                    AppLocalizations.of(context)!.mensaRatingsEmpty,
                    style: Theme.of(context).textTheme.bodyLarge,
                  )))
        ]);
      } else {
        ratingsWidget = SliverList.separated(
            itemCount: comments.length,
            itemBuilder: (context, index) => _submittedRatingTile(comments[index]),
            separatorBuilder: (context, index) => const Divider(
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
                AppLocalizations.of(context)!.mensaRatingsCouldNotLoad,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Padding(padding: EdgeInsets.all(5)),
              ElevatedButton(
                  onPressed: () => _ratingsRetryable.retry(), child: Text(AppLocalizations.of(context)!.retry)),
            ]))
      ]);
    } else {
      ratingsWidget =
          SliverList.list(children: [DelayedLoadingIndicator(name: AppLocalizations.of(context)!.mensaRatings)]);
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
                            .map((additive) => Padding(
                                padding: const EdgeInsets.all(4),
                                child: Chip(
                                    avatar: (additive.icon != null)
                                        ? Icon(
                                            additive.icon,
                                            color: Theme.of(context).colorScheme.onPrimaryContainer,
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
            builder: (context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(meal.category, style: Theme.of(context).textTheme.titleMedium),
                          Text(meal.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium)
                        ])),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: Text("${meal.price}€",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(color: Theme.of(context).textTheme.titleLarge!.color))),
                        if (_stars != null) starsButton(context, _stars),
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
                                starsWithLabel(context, ratingComment.stars),
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
                                  builder: (context) => Dialog(
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

class MealCardSliverBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget Function(BuildContext context) builder;
  final double extent;

  MealCardSliverBarDelegate({required this.builder, this.extent = 80});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(fit: StackFit.loose, children: [
      Container(
        color: Theme.of(context).colorScheme.background,
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
