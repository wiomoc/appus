import 'package:cached_network_image/cached_network_image.dart';
import 'package:campus_flutter/base/helpers/api_backed_state.dart';
import 'package:campus_flutter/organisationsComponent/api/organisations_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

import '../base/helpers/horizontal_slider.dart';
import '../base/helpers/url_launcher.dart';
import 'model/organisation.dart';

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
                        Text(organisation.localizedName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: onPrimaryContainerColor)),
                      ],
                    )),
                ExpansionTile(
                  iconColor: onPrimaryContainerColor,
                  collapsedIconColor: onPrimaryContainerColor,
                  leading: Icon(Icons.link, color: onPrimaryContainerColor),
                  title: Text("Links",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: onPrimaryContainerColor)),
                  shape: Border.symmetric(horizontal: BorderSide(color: Colors.black12.withOpacity(0.1), width: 1)),
                  children: organisation.links
                      .map((link) => ListTile(
                            leading: Icon(_getIcon(link.icon), color: onPrimaryContainerColor),
                            title: Text(link.localizedTitle,
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
                              title: Text(event.localizedTitle),
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
        leadingTrailingPadding: true,
        height: organisation.news.firstOrNull?.localizedTitle == null
            ? 180
            : (organisation.news.firstOrNull?.image == null ? 160 : 250),
        child: (item) => Card(
            margin: EdgeInsets.zero,
            elevation: 2,
            child: SizedBox(
                width: 180,
                child: InkWell(
                  onTap: () {
                    _showNewsDetailsBottomSheet(context, item);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (item.image != null)
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              item.image!.toString(),
                              fit: BoxFit.cover,
                              width: 180,
                              height: 180,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                    child: Padding(padding: EdgeInsets.all(25), child: CircularProgressIndicator()));
                              },
                            )),
                      if (item.localizedTitle != null)
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text(
                                  item.localizedTitle!,
                                  maxLines: item.image == null ? 5 : 3,
                                  overflow: TextOverflow.ellipsis,
                                )),
                                const Padding(padding: EdgeInsets.symmetric(vertical: 1)),
                                Text(
                                  DateFormat.yMMMd().format(item.date),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ]),
                        ))
                    ],
                  ),
                ))));
  }

  void _showNewsDetailsBottomSheet(BuildContext context, News newsItem) {
    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: true,
        context: context,
        builder: (context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.8,
              expand: false,
              builder: (context, scrollController) {
                final isInstagram = newsItem.href.contains("instagram.com");
                return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  if (newsItem.image != null)
                    ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.network(
                          newsItem.image!.toString(),
                          fit: BoxFit.fitWidth,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: Padding(padding: EdgeInsets.all(25), child: CircularProgressIndicator()));
                          },
                        )),
                  Expanded(
                      child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            if (newsItem.localizedTitle != null)
                              Padding(
                                  padding: const EdgeInsets.all(5),
                                  child:
                                      Text(newsItem.localizedTitle!, style: Theme.of(context).textTheme.titleMedium)),
                            if (newsItem.localizedText != null)
                              Padding(
                                  padding: const EdgeInsets.all(1),
                                  child: Html(
                                    data: newsItem.localizedText!,
                                  )),
                            ListTile(
                                onTap: () {
                                  UrlLauncher.urlString(newsItem.href);
                                },
                                leading: Icon(isInstagram ? Icons.photo_outlined : Icons.language),
                                trailing: const Icon(Icons.open_in_new),
                                title: Text(
                                  isInstagram ? "Instagram" : newsItem.href,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ))
                          ]))),
                ]);
              });
        });
  }
}

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  @override
  State<UpdatesPage> createState() {
    return _UpdatesPageState();
  }
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

class _UpdatesPageState extends ApiBackedState<List<Organisation>, UpdatesPage> with ApiPullRefresh {
  @override
  void initState() {
    super.initState();
    load(OrganisationsApiOperation(["stuvus", "fius", "mach", "uni"]), const Duration(minutes: 5));
  }

  @override
  Widget build(BuildContext context) => body();

  @override
  Widget buildBody(List<Organisation> organisations) {
    return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 3),
        itemBuilder: (context, index) => OrganisationView(
              organisations[index],
              key: ValueKey(organisations[index].id),
            ),
        itemCount: organisations.length);
  }

  @override
  // TODO: implement resourceName
  String get resourceName => "Updates";
}
