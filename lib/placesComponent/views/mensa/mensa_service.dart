import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../base/networking/apis/appusBackendApi/appus_backend_api.dart';
import 'model/meal.dart';
import 'model/rating.dart';

class MensaLocation {
  final String id;
  final String name;
  final int? aref;

  const MensaLocation(this.id, this.name, [this.aref]);
}

const mensaLocations = [
  MensaLocation("mensa_stuttgart-vaihingen", "Mensa Stuttgart Vaihingen", 962),
  MensaLocation("mensa_central", "Mensa Central"),
];


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


const lastMensaLocationKey = "lastMensaLocation";

Future<void> setLastMensaLocation(MensaLocation mensaLocation) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.setString(lastMensaLocationKey, mensaLocation.id);
}

Future<MensaLocation> getLastMensaLocation() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final lastMensaLocationId = sharedPreferences.getString(lastMensaLocationKey);
  return mensaLocations.firstWhere((mensaLocation) => mensaLocation.id == lastMensaLocationId, orElse: () => mensaLocations.first);
}
