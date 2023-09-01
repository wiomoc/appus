import 'package:dio/dio.dart';

import 'meal_model.dart';

Future<Map<DateTime, List<Meal>>> fetchMeals(String mensaId) async {
  final client = Dio();
  final response = await client.get("https://sws.maxmanager.xyz/extern/$mensaId.json",
      options: Options(responseType: ResponseType.json));
  final Map<String, dynamic> mealsByDate = response.data.values.first;
  return mealsByDate.map(
      (key, value) => MapEntry(DateTime.parse(key), (value as List<dynamic>).map((m) => Meal.fromJson(m)).toList()));
}
