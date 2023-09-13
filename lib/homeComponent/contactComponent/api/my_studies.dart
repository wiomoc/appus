import 'package:campus_flutter/base/helpers/api_operation.dart';

import '../../../base/networking/apis/campUSApi/campus_api.dart';
import '../../../providers_get_it.dart';
import '../model/study.dart';

class MyStudiesApiOperation extends ApiOperation<List<Study>> {
  @override
  String get cacheKey => "mystudies";

  @override
  List<Study> fromCached(Map<String, dynamic> map) =>
      (map["studies"] as List<dynamic>).map((courseJson) => Study.fromJson(courseJson)).toList();

  @override
  Map<String, dynamic> toCached(List<Study> object) => {"studies": object.map((event) => event.toJson()).toList()};

  @override
  Future<List<Study>> fetchOnline() async {
    final campusApi = getIt.get<CampusApi>();
    final resources = await campusApi.callRestApi("slc.lib.sm/allStudies");
    return resources.map((resource) {
      final study = resource["content"]["studyBasicDto"];

      return Study(
          id: study["id"],
          germanName: study["studyName"]["value"],
          localizedName: CampusApi.getLocalized(study["studyName"])!,
          localizedDegree: CampusApi.getLocalized(study["basicStudyProgrammeLibDto"]["degreeType"]["name"])!);
    }).toList();
  }
}
