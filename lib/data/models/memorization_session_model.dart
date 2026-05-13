import 'person_model.dart';
import 'semester_model.dart';

class MemorizationSessionModel {
  final int id;
  final PersonModel? student;
  final SemesterModel? semester;
  final int pageFrom;
  final int pageTo;
  final String date;

  MemorizationSessionModel({
    required this.id,
    this.student,
    this.semester,
    required this.pageFrom,
    required this.pageTo,
    required this.date,
  });

  factory MemorizationSessionModel.fromJson(Map<String, dynamic> json) {
    return MemorizationSessionModel(
      id: json["id"],
      student: json["student"] != null ? PersonModel.fromJson(json["student"]) : null,
      semester: json["semester"] != null ? SemesterModel.fromJson(json["semester"]) : null,
      pageFrom: json["page_from"] ?? 0,
      pageTo: json["page_to"] ?? 0,
      date: json["date"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "student": student?.toJson(),
      "semester": semester?.toJson(),
      "page_from": pageFrom,
      "page_to": pageTo,
      "date": date,
    };
  }
}