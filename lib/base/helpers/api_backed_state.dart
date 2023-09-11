import 'dart:async';

import 'package:flutter/material.dart';

import '../views/error_handling_view.dart';
import 'api_operation.dart';
import 'delayed_loading_indicator.dart';

abstract class ApiBackedState<T, W extends StatefulWidget> extends State<W> {
  AbstractApiOperation<T>? _apiOperation;

  String get resourceName;

  Widget buildBody(T data);

  T? get data => _apiOperation?.value.cached?.data;

  load(AbstractApiOperation<T> apiOperation, [Duration? maxAge]) {
    final oldOperation = _apiOperation;
    if (oldOperation != null) {
      oldOperation.removeListener(onApiResultChange);
      oldOperation.dispose();
      onApiResultChange();
    }
    _apiOperation = apiOperation;
    apiOperation.addListener(onApiResultChange);
    apiOperation.fetch(maxAge);
  }

  void onApiResultChange() {
    setState(() {});
  }

  Widget body() {
    final apiResult = _apiOperation?.value;

    if (apiResult?.cached != null) {
      return buildBody(apiResult!.cached!.data);
    } else if (apiResult is ErrorApiResult<T>) {
      return ErrorHandlingView(
        error: apiResult.error,
        errorHandlingViewType: ErrorHandlingViewType.fullScreen,
        retry: (force) {
          _apiOperation?.retry();
        },
      );
    } else {
      return DelayedLoadingIndicator(name: resourceName);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _apiOperation?.removeListener(onApiResultChange);
    _apiOperation?.dispose();
  }
}

mixin ApiBackedPageState<T, W extends StatefulWidget> on ApiBackedState<T, W> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  Widget? buildAppBarTitle(T data) => null;

  @override
  void onApiResultChange() {
    super.onApiResultChange();
    final apiResult = _apiOperation?.value;
    if (apiResult is ErrorApiResult<T> && apiResult.cached != null) {
      scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
        content: ErrorHandlingView(
          error: apiResult.error,
          errorHandlingViewType: ErrorHandlingViewType.textOnly,
          retry: (force) {
            _apiOperation?.retry();
          },
        ),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            _apiOperation?.retry();
          },
        ),
      ));
    }
  }

  AppBar appBar() {
    final apiResult = _apiOperation?.value;
    final titleWidget = apiResult?.cached != null ? buildAppBarTitle(apiResult!.cached!.data) : null;
    return AppBar(
      leading: const BackButton(),
      title: titleWidget ?? Text(resourceName),
      bottom: apiResult is LoadingApiResult<T> && apiResult.cached != null
          ? const PreferredSize(
              preferredSize: Size.fromHeight(6.0),
              child: LinearProgressIndicator(),
            )
          : null,
    );
  }
}

mixin ApiPullRefresh<T, W extends StatefulWidget> on ApiBackedState<T, W> {


  @override
  Widget body() {
    if (_apiOperation?.value.cached != null || _apiOperation?.value is ErrorApiResult<T>) {
      return RefreshIndicator(
        onRefresh: () {
          _apiOperation?.retry();
          final completer = Completer();
          void onChange() {
            if (_apiOperation?.value is ErrorApiResult<T> || _apiOperation?.value is FinalApiResult<T>) {
              completer.complete();
              _apiOperation?.removeListener(onChange);
            }
          }
          _apiOperation?.addListener(onChange);
          _apiOperation?.retry();
          return completer.future;
        },
        child: super.body(),
      );
    } else {
      return super.body();
    }
  }
}
