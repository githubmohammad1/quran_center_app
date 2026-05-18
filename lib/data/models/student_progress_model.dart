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
  final String? updatedAt; 

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
      student: (json["student"] != null && json["student"] is Map) 
          ? PersonModel.fromJson(json["student"] as Map<String, dynamic>) 
          : null,
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

  // 🛠️ إضافة معمارية: توفير دالة الـ toJson لتأمين حفظ حالة التقدم التراكمي محلياً في ذاكرة التطبيق عند الحاجة
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
      "updated_at": updatedAt,
    };
  }
}