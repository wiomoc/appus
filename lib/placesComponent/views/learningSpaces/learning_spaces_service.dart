import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/src/adapters/io_adapter.dart';

import 'learning_spaces_model.dart';
import 'dart:async';
import 'dart:io';

class LearningSpacesService {
  Future<LearningSpaces> fetchLearningSpaces() async {
    final learningSpacesJSON =
        await File("C:/Users/Christoph Walcher/Share/STUVUS/Lernraum/dist/data.json").readAsString();
    return LearningSpaces.fromJson(const JsonDecoder().convert(learningSpacesJSON));
  }

  Future<Map<String, double>> fetchOccupation() async {
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
