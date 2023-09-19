import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../base/helpers/horizontal_slider.dart';
import '../../base/helpers/url_launcher.dart';
import '../model/organisation.dart';
import 'news_card.dart';

class OrganisationView extends StatelessWidget {
  final Organisation organisation;

  const OrganisationView(this.organisation, {super.key});

  @override
  Widget build(BuildContext context) {
    final iconImage = CachedNetworkImageProvider(organisation.iconUrl);

    return FutureBuilder(
        future: ColorScheme.fromImageProvider(provider: iconImage),
        builder: (context, snapshot) {
          Color primaryContainerColor =
              snapshot.data?.secondaryContainer ?? Theme.of(context).colorScheme.secondaryContainer;
          Color onPrimaryContainerColor =
              snapshot.data?.onSecondaryContainer ?? Theme.of(context).colorScheme.onSecondaryContainer;
          return Card(
              elevation: 0,
              color: primaryContainerColor.withOpacity(0.7),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                    padding: const EdgeInsets.all(7),
                    child: Row(
                      children: [
                        ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            child: Image(
                              image: iconImage,
                              errorBuilder: (context, error, stackTrace) => const SizedBox(height: 50, width: 10),
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            )),
                        const Padding(padding: EdgeInsets.all(3)),
                        Text(organisation.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: onPrimaryContainerColor)),
                      ],
                    )),
                ExpansionTile(
                  iconColor: onPrimaryContainerColor,
                  collapsedIconColor: onPrimaryContainerColor,
                  collapsedTextColor: onPrimaryContainerColor,
                  leading: Icon(Icons.link, color: onPrimaryContainerColor),
                  title: Text("Links",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: onPrimaryContainerColor)),
                  shape: Border.symmetric(horizontal: BorderSide(color: Colors.black12.withOpacity(0.1), width: 1)),
                  children: organisation.links
                      .map((link) => ListTile(
                            leading: Icon(_getIcon(link.icon), color: onPrimaryContainerColor),
                            title: Text(link.title,
                                style:
                                    Theme.of(context).textTheme.titleMedium?.copyWith(color: onPrimaryContainerColor)),
                            onTap: () {
                              UrlLauncher.urlString(link.href);
                            },
                          ))
                      .toList(),
                ),
                if (organisation.events.isNotEmpty)
                  ExpansionTile(
                    leading: const Icon(Icons.event),
                    title: const Text("Events"),
                    shape: Border(top: BorderSide(color: Colors.black12.withOpacity(0.1), width: 1)),
                    children: organisation.events
                        .map((event) => ListTile(
                              leading: Icon(_getIcon(event.icon)),
                              title: Text(event.title),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    event.date.day.toString().padLeft(2, "0"),
                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                  Text(DateFormat.yMMM().format(event.date),
                                      style: Theme.of(context).textTheme.bodySmall)
                                ],
                              ),
                              onTap: () {
                                UrlLauncher.urlString(event.href);
                              },
                            ))
                        .toList(),
                  ),
                _newsSlider(context),
                const Padding(padding: EdgeInsets.symmetric(vertical: 2))
              ]));
        });
  }

  HorizontalSlider _newsSlider(BuildContext context) {
    return HorizontalSlider(
        data: organisation.news,
        leadingTrailingPadding: 4,
        height: organisation.news.firstOrNull?.title == null
            ? 180
            : (organisation.news.firstOrNull?.image == null ? 160 : 250),
        child: (item) => NewsCard(news: item));
  }

  IconData? _getIcon(String? name) {
    switch (name) {
      case "language":
        return Icons.language_outlined;
      case "local_drink":
        return Icons.local_drink_outlined;
      case "nightlife":
        return Icons.nightlife_outlined;
      case "groups":
        return Icons.groups_outlined;
      case "people":
        return Icons.people_alt_outlined;
      case "book":
        return Icons.book_outlined;
      case "print":
        return Icons.print_outlined;
      case "newspaper":
        return Icons.newspaper_outlined;
      case "child_care":
        return Icons.child_care_outlined;
      case "meeting_room":
        return Icons.meeting_room_outlined;
      case "instagram":
      case "photo":
        return Icons.photo_outlined;
      case "school":
        return Icons.school_outlined;
      default:
        return null;
    }
  }
}
