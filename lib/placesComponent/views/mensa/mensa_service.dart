import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../base/networking/apis/appusBackendApi/appus_backend_api.dart';
import 'meal_model.dart';

Future<Map<DateTime, List<Meal>>> fetchMeals(String mensaId) async {
  final client = Dio();
  final response = await client.get("https://sws.maxmanager.xyz/extern/$mensaId.json",
      options: Options(responseType: ResponseType.json));
  final Map<String, dynamic> mealsByDate = response.data.values.first;
  return mealsByDate.map(
      (key, value) => MapEntry(DateTime.parse(key), (value as List<dynamic>).map((m) => Meal.fromJson(m)).toList()));
}

const String ratingBaseUrl = "$appusBackendBaseUrl/meals";

Future<double> sendRating({required String mealName, required double stars, String? comment, Uint8List? image}) async {
  if (comment?.isEmpty == true) {
    comment = null;
  }

  final client = Dio();
  final response = await client.post("$ratingBaseUrl/rating",
      data: FormData.fromMap({
        "meal_name": mealName,
        "stars": stars,
        "comment": comment,
        "image": image != null ? MultipartFile.fromBytes(image, filename: "image.pic") : null
      }));
  return response.data["stars"];
}

Future<Map<String, double?>> fetchStars(List<String> mealNames) async {
  final client = Dio();
  final response = await client.get("$ratingBaseUrl/stars",
      queryParameters: {"m": mealNames}, options: Options(responseType: ResponseType.json));
  return (response.data as Map<String, dynamic>).map((key, value) => MapEntry(key, value as double?));
}

Future<Rating> fetchRatingDetails(String mealName) async {
  final client = Dio();
  final response = await client.get("$ratingBaseUrl/ratings",
      queryParameters: {"m": mealName}, options: Options(responseType: ResponseType.json));
  return Rating.fromJson(response.data);
}

const lastRatingDateKey = "lastRatingDate";
const lastRatingsKey = "lastRatings";

Future<bool> hasAlreadyRated(String mealName, DateTime today) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final lastRatingDate = sharedPreferences.getString(lastRatingDateKey);
  if (lastRatingDate == null) return false;
  if (DateTime.parse(lastRatingDate) != today) return false;
  final lastRatings = sharedPreferences.getStringList(lastRatingsKey);
  if (lastRatings == null) return false;
  return lastRatings.contains(mealName);
}

Future<void> setRated(String mealName, DateTime today) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final lastRatingDate = sharedPreferences.getString(lastRatingDateKey);
  if (lastRatingDate == null || DateTime.parse(lastRatingDate) != today) {
    await sharedPreferences.setString(lastRatingDateKey, today.toIso8601String());
    await sharedPreferences.setStringList(lastRatingsKey, [mealName]);
  } else {
    await sharedPreferences.setStringList(
        lastRatingsKey, (sharedPreferences.getStringList(lastRatingsKey) ?? []) + [mealName]);
  }
}
