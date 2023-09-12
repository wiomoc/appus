import 'package:campus_flutter/examsComponent/model/planned_exam.dart';

import '../../base/helpers/api_operation.dart';
import '../../base/networking/apis/campUSApi/campus_api.dart';
import '../../providers_get_it.dart';

class MyRegisteredExamsApiOperation extends ApiOperation<List<PlannedExam>> {
  @override
  String get cacheKey => "myRegisteredExams";

  @override
  List<PlannedExam> fromCached(Map<String, dynamic> map) =>
      (map["exams"] as List<dynamic>).map((courseJson) => PlannedExam.fromJson(courseJson)).toList();

  @override
  Map<String, dynamic> toCached(List<PlannedExam> object) =>
      {"exams": object.map((course) => course.toJson()).toList()};

  @override
  Future<List<PlannedExam>> fetchOnline() async {
    final campusApi = getIt.get<CampusApi>();

    final examOffers = await campusApi.callRestApi("slc.xm.exr/registered-exams", resourcesKey: "examOffers");
    return examOffers.map((exam) {
      final appointment = (exam["appointments"] as List<dynamic>?)?.firstOrNull;
      final String? roomId = appointment?["url"]?["href"]?.split("/")?.last;

      DateTime? date;
      if (exam["examDate"] != null && exam["examStart"] != null) {
        date = DateTime.parse(exam["examDate"]["value"] + "T" + exam["examStart"]["value"]);
      }

      return PlannedExam(
          id: exam["examId"],
          courseId: exam["courseId"],
          courseName: CampusApi.getLocalized(exam["courseName"])!,
          roomName: appointment?["displayName"],
          roomId: roomId != null ? int.tryParse(roomId) : null,
          deregistrationEnd: DateTime.parse(exam["deRegistrationEnd"]["value"]),
          examers: (exam["examPersons"] as List<dynamic>)
              .where((examPerson) => examPerson["functionName"]["value"] == "Prüfer*in")
              .expand((examPerson) => (examPerson["identities"] as List<dynamic>)
              .map((identity) => "${identity["firstName"]} ${identity["lastName"]}"))
              .toList(),
          date: date);
    }).toList();
  }
}
