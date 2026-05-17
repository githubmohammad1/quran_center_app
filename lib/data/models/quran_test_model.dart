import 'person_model.dart';
import 'semester_model.dart';
import 'surah_model.dart';

class QuranTestModel {
  final int id;
  final PersonModel? student;
  final SemesterModel? semester;
  final String testType; // PART, SURAH
  final int? partNumber;
  final SurahModel? surah;
  final String grade;
  final String date;
  final String notes;

  QuranTestModel({
    required this.id,
    this.student,
    this.semester,
    required this.testType,
    this.partNumber,
    this.surah,
    required this.grade,
    required this.date,
    required this.notes,
  });

  factory QuranTestModel.fromJson(Map<String, dynamic> json) {
    return QuranTestModel(
      id: json["id"],
      student: (json["student"] != null && json["student"] is Map) ? PersonModel.fromJson(json["student"]) : null,
      semester: (json["semester"] != null && json["semester"] is Map) ? SemesterModel.fromJson(json["semester"]) : null,
      testType: json["test_type"] ?? "",
      partNumber: json["part_number"],
      surah: (json["surah"] != null && json["surah"] is Map) ? SurahModel.fromJson(json["surah"]) : null,
      grade: json["grade"] ?? "",
      date: json["date"] ?? "",
      notes: json["notes"] ?? "",
    );
  }
}