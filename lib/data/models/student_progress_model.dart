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
  final String? updatedAt; // تم إضافتها لتطابق الجانغو

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
    this.updatedAt,
  });

  factory StudentProgressModel.fromJson(Map<String, dynamic> json) {
    return StudentProgressModel(
      id: json["id"] ?? 0,
      student: (json["student"] != null && json["student"] is Map) ? PersonModel.fromJson(json["student"]) : null,
      totalPagesMemorized: json["total_pages_memorized"] ?? 0,
      lastPage: json["last_page"] ?? 0,
      points: json["points"] ?? 0,
      totalPartsTested: json["total_parts_tested"] ?? 0,
      totalSurahsTested: json["total_surahs_tested"] ?? 0,
      lastPartTested: json["last_part_tested"] ?? 0,
      lastTestDate: json["last_test_date"],
      updatedAt: json["updated_at"],
    );
  }
}