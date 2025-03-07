import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

import '../../base/helpers/url_launcher.dart';
import '../../base/views/child_sized_draggable_scrollable_sheet.dart';
import '../model/news.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.news});

  final News news;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        child: SizedBox(
            width: 180,
            child: InkWell(
              onTap: () {
                _showNewsDetailsBottomSheet(context, news);
              },
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (news.image != null)
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                            imageUrl: news.image!.toString(),
                            fit: BoxFit.cover,
                            width: 180,
                            height: 180,
                            fadeOutDuration: Duration.zero,
                            fadeInDuration: Duration.zero,
                            placeholder: (context, string) =>
                                Image.asset("assets/images/placeholders/news_placeholder.png", fit: BoxFit.fill),
                            errorWidget: (context, url, error) => Image.asset(
                                  "assets/images/placeholders/news_placeholder.png",
                                )))
                  else
                    const Padding(padding: EdgeInsets.all(2)),
                  if (news.title != null)
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Text(
                              news.title!,
                              maxLines: news.image == null ? 5 : 3,
                              overflow: TextOverflow.ellipsis,
                            )),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 1)),
                            Text(
                              DateFormat.yMMMd().format(news.date),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ]),
                    ))
                ],
              ),
            )));
  }

  void _showNewsDetailsBottomSheet(BuildContext context, News newsItem) {
    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: true,
        context: context,
        builder: (context) {
          return Container(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ChildSizedDraggableScrollableSheet(builder: (context) {
                final isInstagram = newsItem.link.contains("instagram.com");
                return Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
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
                        ))
                  else
                    const Padding(padding: EdgeInsets.all(5.0)),
                  Flexible(
                      child: SingleChildScrollView(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            if (newsItem.title != null)
                              Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: Text(newsItem.title!, style: Theme.of(context).textTheme.titleMedium)),
                            if (newsItem.text != null)
                              Padding(
                                  padding: const EdgeInsets.all(1),
                                  child: Html(
                                    data: newsItem.text!,
                                  )),
                            ListTile(
                                onTap: () {
                                  UrlLauncher.urlString(newsItem.link);
                                },
                                leading: Icon(isInstagram ? Icons.photo_outlined : Icons.language),
                                trailing: const Icon(Icons.open_in_new),
                                title: Text(
                                  isInstagram ? "Instagram" : newsItem.link,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ))
                          ]))),
                ]);
              }));
        });
  }
}