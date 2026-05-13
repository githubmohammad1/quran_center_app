import 'person_model.dart';

class StudentProgressModel {
  final int id;
  final PersonModel? student;
  final int totalPagesMemorized;
  final int lastPage;
  final int points;
  final int totalPartsTested;
  final int totalSurahsTested;
  final int lastPartTested;
  final String? lastTestDate;

  StudentProgressModel({
    required this.id,
    this.student,
    required this.totalPagesMemorized,
    required this.lastPage,
    required this.points,
    required this.totalPartsTested,
    required this.totalSurahsTested,
    required this.lastPartTested,
    this.lastTestDate,
  });

  factory StudentProgressModel.fromJson(Map<String, dynamic> json) {
    return StudentProgressModel(
      id: json["id"] ?? 0,
      student: json["student"] != null ? PersonModel.fromJson(json["student"]) : null,
      totalPagesMemorized: json["total_pages_memorized"] ?? 0,
      lastPage: json["last_page"] ?? 0,
      points: json["points"] ?? 0,
      totalPartsTested: json["total_parts_tested"] ?? 0,
      totalSurahsTested: json["total_surahs_tested"] ?? 0,
      lastPartTested: json["last_part_tested"] ?? 0,
      lastTestDate: json["last_test_date"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "student": student?.toJson(),
      "total_pages_memorized": totalPagesMemorized,
      "last_page": lastPage,
      "points": points,
      "total_parts_tested": totalPartsTested,
      "total_surahs_tested": totalSurahsTested,
      "last_part_tested": lastPartTested,
      "last_test_date": lastTestDate,
    };
  }
}