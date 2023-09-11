import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:stash/stash_api.dart';

import '../../providers_get_it.dart';

class ApiResponseData<T> {
  final T data;
  final DateTime fetchTime;

  const ApiResponseData(this.data, this.fetchTime);

  factory ApiResponseData.fresh(T data) => ApiResponseData(data, DateTime.now());
}

sealed class ApiResult<T> {
  final ApiResponseData<T>? cached;

  const ApiResult([this.cached]);
}

class LoadingApiResult<T> extends ApiResult<T> {
  const LoadingApiResult([super.cached]);

  LoadingApiResult<T> withCached(ApiResponseData<T> cached) => LoadingApiResult(cached);
}

class ErrorApiResult<T> extends ApiResult<T> {
  final Object error;

  const ErrorApiResult(this.error, [super.cached]);

  ErrorApiResult<T> withCached(ApiResponseData<T> cached) => ErrorApiResult(this.error, cached);
}

class FinalApiResult<T> extends ApiResult<T> {
  final ApiResponseData<T>? response;

  FinalApiResult(this.response) : super(response);
}

class SimpleApiOperation<T> extends ApiOperation<T> {
  final Map<String, dynamic> Function(T object) _toCached;
  final T Function(Map<String, dynamic>) _fromCached;
  final Future<T> Function(CancelToken cancelToken) _fetchOnline;
  final String _cacheKey;

  SimpleApiOperation(this._toCached, this._fromCached, this._fetchOnline, this._cacheKey);

  @override
  Future<T> fetchOnline() async {
    return _fetchOnline(cancelToken);
  }

  @override
  String get cacheKey => _cacheKey;

  @override
  T fromCached(Map<String, dynamic> map) => _fromCached(map);

  @override
  Map<String, dynamic> toCached(T object) => _toCached(object);
}

abstract class AbstractApiOperation<T> implements ValueListenable<ApiResult<T>> {
  void dispose();

  void fetch([Duration? maxAge]);

  void retry();
}

abstract class ApiOperation<T> with ChangeNotifier implements AbstractApiOperation<T> {
  ApiResult<T> _currentResult = LoadingApiResult<T>();
  CancelToken cancelToken = CancelToken();

  String get cacheKey;

  Map<String, dynamic> toCached(T object);

  T fromCached(Map<String, dynamic> map);

  @override
  ApiResult<T> get value => _currentResult;

  @override
  void fetch([Duration? maxAge]) {
    final cache = getIt<Cache<Map>>();
    void fetchOnlineAndStoreToCache() {
      fetchOnline().then((data) {
        final response = ApiResponseData.fresh(data);
        _setResult(FinalApiResult(response));
        final cachedMap = toCached(data);
        cachedMap["lastRefresh"] = response.fetchTime.toIso8601String();
        return cache.put(cacheKey, cachedMap, delegate: (builder) => builder..expiryDuration = Duration(days: 1));
      }).onError((error, stackTrace) {
        if (!(error is DioException && error.type == DioExceptionType.cancel)) {
          _setResult(ErrorApiResult(error!, _currentResult.cached));
        }
      });
    }

    if (_currentResult.cached == null) {
      _fetchCached(cache).then((data) {
        if (data != null) {
          final currentResult = _currentResult;
          if (maxAge != null) {
            if (DateTime.now().difference(data.fetchTime) < maxAge) {
              _setResult(FinalApiResult(data));
            } else {
              _setResult(LoadingApiResult(data));
              fetchOnlineAndStoreToCache();
            }
          } else if (currentResult is LoadingApiResult<T>) {
            _setResult(currentResult.withCached(data));
          } else if (currentResult is ErrorApiResult<T>) {
            _setResult(currentResult.withCached(data));
          }
        } else if (maxAge != null) {
          fetchOnlineAndStoreToCache();
        }
      });
    }

    if (maxAge == null) {
      fetchOnlineAndStoreToCache();
    }
  }

  void retry() {
    cancelToken.cancel("retrying");
    cancelToken = CancelToken();
    _setResult(LoadingApiResult(_currentResult.cached));
    fetch();
  }

  void _setResult(ApiResult<T> newResult) {
    _currentResult = newResult;
    notifyListeners();
  }

  Future<T> fetchOnline();

  Future<ApiResponseData<T>?> _fetchCached(Cache<Map> cache) async {
    final Map? cachedMap = await cache.get(cacheKey);
    return cachedMap != null
        ? ApiResponseData(fromCached(cleanMap(cachedMap)), DateTime.parse(cachedMap["lastRefresh"]))
        : null;
  }

  @override
  void dispose() {
    super.dispose();
    cancelToken.cancel("disposed");
  }
}

dynamic cleanMapEntry(dynamic value) {
  if (value is Map) {
    return cleanMap(value);
  } else if (value is List) {
    return value.map(cleanMapEntry).toList();
  } else {
    return value;
  }
}

Map<String, dynamic> cleanMap(Map map) => map.map((key, value) => MapEntry(key.toString(), cleanMapEntry(value)));

class MergedApiOperation<A, B> with ChangeNotifier implements AbstractApiOperation<(A?, B?)> {
  final AbstractApiOperation<A> firstOperation;
  final AbstractApiOperation<B> secondOperation;

  ApiResult<(A?, B?)> _currentResult = LoadingApiResult<(A?, B?)>();

  MergedApiOperation(this.firstOperation, this.secondOperation) {
    firstOperation.addListener(_onApiResultChange);
    secondOperation.addListener(_onApiResultChange);
  }

  @override
  ApiResult<(A?, B?)> get value => _currentResult;

  @override
  void fetch([Duration? maxAge]) {
    firstOperation.fetch(maxAge);
    secondOperation.fetch(maxAge);
  }

  @override
  void retry() {
    if (firstOperation.value is ErrorApiResult<A> || secondOperation.value is ErrorApiResult<B>) {
      if (firstOperation.value is ErrorApiResult<A>) {
        firstOperation.retry();
      }
      if (secondOperation.value is ErrorApiResult<A>) {
        secondOperation.retry();
      }
    } else {
      firstOperation.retry();
      secondOperation.retry();
    }
  }

  ApiResponseData<(A?, B?)>? _mergeResult(
      ApiResponseData<A>? firstApiResponseData, ApiResponseData<B>? secondApiResponseData) {
    if (firstApiResponseData == null && secondApiResponseData == null) {
      return null;
    } else if (firstApiResponseData == null) {
      return ApiResponseData((null, secondApiResponseData!.data), secondApiResponseData.fetchTime);
    } else if (secondApiResponseData == null) {
      return ApiResponseData((firstApiResponseData.data, null), firstApiResponseData.fetchTime);
    } else {
      return ApiResponseData((firstApiResponseData.data, secondApiResponseData.data), firstApiResponseData.fetchTime);
    }
  }

  void _onApiResultChange() {
    final firstOperationValue = firstOperation.value;
    final secondOperationValue = secondOperation.value;

    if ((firstOperationValue is FinalApiResult<A> && secondOperationValue is FinalApiResult<B>)) {
      _setResult(FinalApiResult(_mergeResult(firstOperationValue.cached, secondOperationValue.cached)));
    } else if (firstOperationValue is ErrorApiResult<A>) {
      _setResult(ErrorApiResult(
          firstOperationValue.error, _mergeResult(firstOperationValue.cached, secondOperationValue.cached)));
    } else if (secondOperationValue is ErrorApiResult<B>) {
      _setResult(ErrorApiResult(
          secondOperationValue.error, _mergeResult(firstOperationValue.cached, secondOperationValue.cached)));
    } else if ((firstOperationValue is LoadingApiResult<A> || secondOperationValue is LoadingApiResult<B>)) {
      _setResult(LoadingApiResult(_mergeResult(firstOperationValue.cached, secondOperationValue.cached)));
    }
  }

  void _setResult(ApiResult<(A?, B?)> newResult) {
    _currentResult = newResult;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    firstOperation.removeListener(_onApiResultChange);
    secondOperation.removeListener(_onApiResultChange);
  }
}
