import 'package:campus_flutter/base/helpers/delayed_loading_indicator.dart';
import 'package:campus_flutter/base/helpers/retryable.dart';
import 'package:campus_flutter/base/views/error_handling_view.dart';
import 'package:campus_flutter/base/views/generic_stream_builder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../base/helpers/horizontal_slider.dart';
import '../base/helpers/url_launcher.dart';
import 'models.dart';
import 'organisations_service.dart';

class OrganisationView extends StatelessWidget {
  final Organisation organisation;

  const OrganisationView(this.organisation, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.05),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.all(7),
              child: Row(
                children: [
                  ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: Image.network(
                        organisation.iconUrl.toString(),
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      )),
                  const Padding(padding: EdgeInsets.all(3)),
                  Text(organisation.localizedName, style: Theme.of(context).textTheme.titleMedium)
                ],
              )),
          ExpansionTile(
            leading: const Icon(Icons.link),
            title: const Text("Links"),
            shape: Border.symmetric(horizontal: BorderSide(color: Colors.black12.withOpacity(0.1), width: 1)),
            children: organisation.links
                .map((link) => ListTile(
                      leading: Icon(_getIcon(link.icon)),
                      title: Text(link.localizedTitle),
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
                            Text(DateFormat.yMMM().format(event.date), style: Theme.of(context).textTheme.bodySmall)
                          ],
                        ),
                        onTap: () {
                          UrlLauncher.urlString(event.href);
                        },
                      ))
                  .toList(),
            ),
          HorizontalSlider(
              data: organisation.news,
              leadingTrailingPadding: false,
              height: organisation.news.firstOrNull?.localizedTitle == null ? 170 : 250,
              child: (item) {
                return SizedBox(
                    width: 170,
                    child: Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            UrlLauncher.urlString(item.href);
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
                                      fit: BoxFit.fitWidth,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(
                                            child: Padding(
                                                padding: EdgeInsets.all(25), child: CircularProgressIndicator()));
                                      },
                                    )),
                              if (item.localizedTitle != null)
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(
                                      item.localizedTitle!,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Padding(padding: EdgeInsets.symmetric(vertical: 1)),
                                    Text(
                                      DateFormat.yMMMd().format(item.date),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ]),
                                )
                            ],
                          ),
                        )));
              }),
          Padding(padding: const EdgeInsets.symmetric(vertical: 2))
        ]));
  }
}

class OrganisationsView extends StatefulWidget {
  const OrganisationsView({super.key});

  @override
  OrganisationsState createState() {
    return OrganisationsState();
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

class OrganisationsState extends State<OrganisationsView> {
  late Retryable<List<Organisation>> _organisationsRetryable;

  @override
  void initState() {
    super.initState();

    _organisationsRetryable = Retryable(() => OrganisationsService().fetchOrganisations(["stuvus", "fius", "uni"]));
  }

  @override
  Widget build(BuildContext context) {
    return GenericStreamBuilder(
        stream: _organisationsRetryable.stream,
        dataBuilder: (context, organisations) {
          return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 3),
              itemBuilder: (context, index) => OrganisationView(organisations[index]),
              itemCount: organisations.length);
        },
        errorBuilder: (context, error) => ErrorHandlingView(
              error: error,
              errorHandlingViewType: ErrorHandlingViewType.fullScreen,
              retry: (force) {
                _organisationsRetryable.retry();
              },
            ),
        loadingBuilder: (context) => const DelayedLoadingIndicator(name: "Organisations"));
  }
}
