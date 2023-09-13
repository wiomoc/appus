import 'package:campus_flutter/base/helpers/api_operation.dart';
import 'package:dio/dio.dart';

import '../model/meal.dart';

class MealsApiOperation extends ApiOperation<Map<DateTime, List<Meal>>> {
  final String mensaId;

  MealsApiOperation(this.mensaId);

  @override
  String get cacheKey => "mensa$mensaId";

  @override
  Map<DateTime, List<Meal>> fromCached(Map<String, dynamic> map) => map.map(
      (key, value) => MapEntry(DateTime.parse(key), (value as List<dynamic>).map((m) => Meal.fromJson(m)).toList()));

  @override
  Map<String, dynamic> toCached(Map<DateTime, List<Meal>> object) =>
      object.map((key, value) => MapEntry(key.toString(), value));

  @override
  Future<Map<DateTime, List<Meal>>> fetchOnline() async {
    final client = Dio();
    final response = await client.get("https://sws.maxmanager.xyz/extern/$mensaId.json",
        options: Options(responseType: ResponseType.json));
    final Map<String, dynamic> mealsByDate = response.data.values.first;
    return mealsByDate.map(
        (key, value) => MapEntry(DateTime.parse(key), (value as List<dynamic>).map((m) => Meal.fromJson(m)).toList()));
  }
}
