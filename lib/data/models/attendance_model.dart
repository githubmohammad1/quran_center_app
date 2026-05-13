import 'person_model.dart';

class AttendanceModel {
  final int id;
  final PersonModel? student;
  final String date;
  final String status;

  AttendanceModel({
    required this.id,
    this.student,
    required this.date,
    required this.status,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json["id"],
      student: json["student"] != null ? PersonModel.fromJson(json["student"]) : null,
      date: json["date"] ?? "",
      status: json["status"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "student": student?.toJson(),
      "date": date,
      "status": status,
    };
  }
}