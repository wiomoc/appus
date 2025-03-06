import 'package:campus_flutter/base/helpers/horizontal_slider.dart';
import 'package:flutter/material.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

import '../../../base/helpers/api_backed_state.dart';
import '../../../base/views/error_handling_view.dart';
import '../../../homeComponent/widgetComponent/views/widget_frame_view.dart';
import '../../api/news_api.dart';
import '../../model/news.dart';
import '../news_card.dart';

class NewsHomeWidget extends StatefulWidget {
  const NewsHomeWidget({super.key});

  @override
  State<NewsHomeWidget> createState() => _NewsHomeWidgetState();
}

class _NewsHomeWidgetState extends ApiBackedState<List<News>, NewsHomeWidget> {
  @override
  void initState() {
    super.initState();
    load(NewsApiOperation(), const Duration(minutes: 15));
  }

  @override
  Widget? buildBody(List<News> data) {
    if (data.isNotEmpty) {
      return HorizontalSlider(
          data: data,
          height: 250,
          child: (news) {
            return NewsCard(news: news);
          });
    } else {
      return Card(child: Center(child: Text(AppLocalizations.of(context)!.newsEmpty)));
    }
  }

  @override
  String get resourceName => AppLocalizations.of(context)!.newsLatest;

  @override
  Widget build(BuildContext context) {
    return WidgetFrameView(title: resourceName, child: SizedBox(height: 250, child: body()));
  }

  @override
  ErrorHandlingViewType get errorHandlingViewType => ErrorHandlingViewType.descriptionOnly;
}
