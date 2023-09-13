import 'package:campus_flutter/base/helpers/api_operation.dart';

import '../../../base/networking/apis/campUSApi/campus_api.dart';
import '../../../providers_get_it.dart';



class MyNameApiOperation extends ApiOperation<String> {
  @override
  String get cacheKey => "myname";

  @override
  String fromCached(Map<String, dynamic> map) => map["name"];

  @override
  Map<String, dynamic> toCached(String object) => {"name": object};

  @override
  Future<String> fetchOnline() async {
    final campusApi = getIt.get<CampusApi>();

    final profiles = await campusApi.callRestApi("brm.lib.dtop.home/v1/desktop/profile");
    return profiles[0]["content"]["desktopProfileLibDto"]["nickname"];
  }
}