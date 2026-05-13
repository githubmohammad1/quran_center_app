import 'person_model.dart';
import 'semester_model.dart';

class HalqaModel {
  final int id;
  final String name;
  final PersonModel? teacher;
  final List<PersonModel> students;
  final SemesterModel? semester;

  HalqaModel({
    required this.id,
    required this.name,
    this.teacher,
    required this.students,
    this.semester,
  });

  factory HalqaModel.fromJson(Map<String, dynamic> json) {
    return HalqaModel(
      id: json["id"],
      name: json["name"] ?? "",
      teacher: json["teacher"] != null ? PersonModel.fromJson(json["teacher"]) : null,
      // جلب مصفوفة الطلاب بطريقة آمنة
      students: json["students"] != null
          ? (json["students"] as List).map((e) => PersonModel.fromJson(e)).toList()
          : [],
      semester: json["semester"] != null ? SemesterModel.fromJson(json["semester"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "teacher": teacher?.toJson(),
      "students": students.map((e) => e.toJson()).toList(),
      "semester": semester?.toJson(),
    };
  }
}