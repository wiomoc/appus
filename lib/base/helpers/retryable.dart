import 'dart:async';

import 'package:flutter/foundation.dart';

class Retryable<T> {
  late Stream<T> stream;
  late VoidCallback retry;

  Retryable(Future<T> Function() function) {
    final streamController = StreamController<T>();

    void retry() {
      function().then((value) {
        streamController.add(value);
      }).onError((error, stackTrace) {
        streamController.addError(error!, stackTrace);
      });
    }

    retry();
    stream = streamController.stream;
    this.retry = retry;
  }
}