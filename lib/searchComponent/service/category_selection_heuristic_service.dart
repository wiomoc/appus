import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../model/vocab.dart';
import '../views/search_body_view.dart';

class CategorySelectionHeuristicService {
  late Interpreter interpreter;
  late HashMap vocab2;

  CategorySelectionHeuristicService() {
    initializeNaturalLanguageModel();
  }

  Future initializeNaturalLanguageModel() async {
    interpreter =
    await Interpreter.fromAsset('assets/models/english_bert_30.tflite');
  }


  Future<List<dynamic>> search(int index, String searchString) async {
    if (searchString.isEmpty) {
      return [];
    }
    if (index == 0) {
      final tokens = await tokenizeBert(searchString);
      var output = List.filled(1 * 6, 0).reshape([1, 6]);
      interpreter.run(tokens, output);
      final probabilities = output.first as List<double>;
      final List<String> categoryNames = [
        "cafeterias",
        "calendar",
        "calendar",
        "grade",
        "movie",
        "news",
        "studyroom"
      ];
      final categories = Map.fromIterables(categoryNames, probabilities);
      List<MapEntry<String, double>> sortedEntries = categories.entries
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final sortedCategories = Map
          .fromEntries(sortedEntries)
          .keys
          .map((key) => SearchCategory.fromString(key))
          .toList();
      return sortedCategories;
    } else {
      switch (index) {
        case 1:
          return [SearchCategory.grade];
        case 2:
          return [SearchCategory.lectures];
        case 3:
          return [SearchCategory.calendar];
        case 4:
        default:
          return [SearchCategory.cafeterias, SearchCategory.studyRoom];
      }
    }
  }


  Future<List<int>> tokenizeBert(String input) async {
    List<String> substrings = input.split(" ");
    List<int> tokenized = [];

    for (var string in substrings) {
      if (vocab.containsKey(string)) {
        tokenized.add(vocab[string]!);
      } else {
        int start = 0;
        while (start < string.length) {
          int length = string.length;
          while (length >= start) {
            String tempString = string.substring(start, length);
            if (vocab.containsKey(tempString)) {
              tokenized.add(vocab[tempString]!);
              start = length;
              break;
            }
            length--;
          }
          if (start != length) {
            tokenized.add(vocab["[UNK]"]!);
            start = string.length;
          }
        }
      }
    }

    int paddingNeeded = 30 - tokenized.length;
    if (paddingNeeded > 0) {
      tokenized.addAll(List<int>.filled(paddingNeeded, 0));
    } else if (paddingNeeded < 0) {
      tokenized = tokenized.sublist(0, 30);
    }

    return tokenized;
  }
}