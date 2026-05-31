import 'person_model.dart';
import 'semester_model.dart';

class MemorizationSessionModel {
  final int id;
  final PersonModel? student;
  final SemesterModel? semester;
  final int pageFrom;
  final int pageTo;
  final String date;
  final String grade;

  MemorizationSessionModel({
    required this.id,
    this.student,
    this.semester,
    required this.pageFrom,
    required this.pageTo,
    required this.date,
    this.grade = "excellent", 
  });

  factory MemorizationSessionModel.fromJson(Map<String, dynamic> json) {
    return MemorizationSessionModel(
      id: json["id"] ?? 0, // 🚀 تحصين الجودة ضد الـ Null Pointer
      student: (json["student"] != null && json["student"] is Map) 
          ? PersonModel.fromJson(json["student"] as Map<String, dynamic>) 
          : null,
      semester: (json["semester"] != null && json["semester"] is Map) 
          ? SemesterModel.fromJson(json["semester"] as Map<String, dynamic>) 
          : null,
      pageFrom: json["page_from"] ?? 0,
      pageTo: json["page_to"] ?? 0,
      date: json["date"] ?? "",
      grade: json["grade"] ?? "excellent",
    );
  }

  // 🚀 إضافة هندسية: تمكين التسييل للحفظ المحلي والكاش
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "student": student?.toJson(),
      "semester": semester?.toJson(),
      "page_from": pageFrom,
      "page_to": pageTo,
      "date": date,
      "grade": grade,
    };
  }
}