import 'dart:convert';
import 'dart:io';

import 'package:campus_flutter/base/helpers/api_operation.dart';
import 'package:dio/dio.dart';
import 'package:dio/src/adapters/io_adapter.dart';


class TikOccupationsApiOperation extends ApiOperation<Map<String, double>> {
  @override
  String get cacheKey => "occupations";

  @override
  Map<String, double> fromCached(Map<String, dynamic> map) => map.cast<String, double>();

  @override
  Map<String, dynamic> toCached(Map<String, double> object) => object.cast<String, dynamic>();

  @override
  Future<Map<String, double>> fetchOnline() async {
    final client = Dio();
    (client.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
        () => HttpClient()..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final response = await client.get("https://netstatus.tik.uni-stuttgart.de/api/v1/spaces",
        options: Options(
          responseType: ResponseType.plain,
        ));
    final responseData = const JsonDecoder().convert(response.data);
    return (responseData as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, (value as Map<String, dynamic>)["usage"]! as double));
  }
}
