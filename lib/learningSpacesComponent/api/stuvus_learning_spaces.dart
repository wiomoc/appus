import 'package:campus_flutter/base/helpers/api_operation.dart';
import 'package:dio/dio.dart';

import '../model/learning_spaces.dart';

const learningSpacesBaseUrl = "https://lernraeume.stuvus.uni-stuttgart.de";

class LearningSpacesApiOperation extends ApiOperation<LearningSpaces> {
  @override
  String get cacheKey => "learningSpaces";

  @override
  LearningSpaces fromCached(Map<String, dynamic> map) => LearningSpaces.fromJson(map);

  @override
  Map<String, dynamic> toCached(LearningSpaces object) => object.toJson();

  @override
  Future<LearningSpaces> fetchOnline() async {
    final client = Dio();
    final response = await client.get("$learningSpacesBaseUrl/data.json",
        options: Options(
          responseType: ResponseType.json,
        ));
    return LearningSpaces.fromJson(response.data);
  }
}

String expandImageUrl(String relativeImageUrl) => "$learningSpacesBaseUrl/$relativeImageUrl";
