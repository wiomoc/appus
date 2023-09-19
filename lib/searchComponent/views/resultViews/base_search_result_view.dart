import 'dart:async';
import 'dart:math';

import 'package:campus_flutter/base/helpers/api_operation.dart';
import 'package:campus_flutter/base/helpers/delayed_loading_indicator.dart';
import 'package:campus_flutter/searchComponent/protocols/searchable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../base/helpers/padded_divider.dart';
import '../../../base/views/error_handling_view.dart';
import '../../../homeComponent/widgetComponent/views/widget_frame_view.dart';
import '../../protocols/global_search.dart';

abstract class BaseSearchResultView<T extends Searchable> extends StatefulWidget {
  final String searchText;

  String getTitle(BuildContext context);

  AbstractApiOperation<List<T>> search();

  Widget buildResultEntry(BuildContext context, T entry);

  const BaseSearchResultView({super.key, required this.searchText});

  @override
  State<StatefulWidget> createState() {
    return _BaseSearchResultView<T>();
  }
}

class _BaseSearchResultView<T extends Searchable> extends State<BaseSearchResultView<T>> {
  late String _searchText;
  ApiResult<List<T>> _searchResults = LoadingApiResult<List<T>>();
  AbstractApiOperation<List<T>>? _searchOperation;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchText = widget.searchText;
    _search();
  }

  @override
  Widget build(BuildContext context) {
    late final Widget body;
    final searchResults = _searchResults;
    final cachedData = searchResults.cached?.data;
    if (cachedData != null) {
      if (cachedData.isNotEmpty) {
        body = ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => widget.buildResultEntry(context, cachedData[index]),
            separatorBuilder: (context, index) => const PaddedDivider(
                  height: 0,
                ),
            itemCount: min(cachedData.length, 5));
      } else {
        body = SizedBox(height: 100, child: Center(child: Text(AppLocalizations.of(context)!.searchNoResults)));
      }
    } else if (searchResults is ErrorApiResult<List<T>>) {
      body = Column(children: [
        ErrorHandlingView(error: searchResults.error, errorHandlingViewType: ErrorHandlingViewType.descriptionOnly),
        ElevatedButton(onPressed: _searchOperation?.retry, child:  Text(AppLocalizations.of(context)!.retry))
      ]);
    } else {
      body = DelayedLoadingIndicator(name: widget.getTitle(context));
    }

    return WidgetFrameView(
        title: widget.getTitle(context),
        subtitle: (searchResults is LoadingApiResult<List<T>> && searchResults.cached != null)
            ? const LinearProgressIndicator()
            : null,
        child: Card(child: body));
  }

  void _search() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _searchOnline();
    });

    final oldSearchResults = _searchResults;
    if (oldSearchResults.cached != null) {
      final filteredCachedData =
          GlobalSearch.tokenSearch(_searchText, oldSearchResults.cached!.data).map((result) => result.$1).toList();
      setState(() {
        _searchResults =
            oldSearchResults.withCached(ApiResponseData(filteredCachedData, oldSearchResults.cached!.fetchTime));
      });
    }
  }

  void _searchOnline() {
    final newSearchOperation = widget.search();
    final oldSearchOperation = _searchOperation;
    if (oldSearchOperation != null) {
      oldSearchOperation.removeListener(_onUpdate);
      oldSearchOperation.dispose();
    }
    _searchOperation = newSearchOperation;
    newSearchOperation.fetch(const Duration(minutes: 1));
    newSearchOperation.addListener(_onUpdate);
  }

  void _onUpdate() {
    setState(() {
      final oldSearchResults = _searchResults;
      var newSearchResults = _searchOperation!.value;
      if (newSearchResults.cached == null && oldSearchResults.cached != null) {
        newSearchResults = newSearchResults.withCached(oldSearchResults.cached!);
      }
      _searchResults = newSearchResults;
    });
  }

  @override
  didUpdateWidget(BaseSearchResultView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchText != _searchText) {
      setState(() {
        _searchText = widget.searchText;
      });
      _search();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _debounce?.cancel();
    _searchOperation?.removeListener(_onUpdate);
    _searchOperation?.dispose();
  }
}
//mixin
