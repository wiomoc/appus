import 'package:campus_flutter/searchComponent/protocols/global_search.dart';
import 'package:campus_flutter/searchComponent/protocols/searchable.dart';

abstract class SearchViewModel<T extends Searchable> {

  Future search({bool forcedRefresh = false, required String query});
}
