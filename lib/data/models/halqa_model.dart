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
      teacher: (json["teacher"] != null && json["teacher"] is Map) ? PersonModel.fromJson(json["teacher"]) : null,
      // تأمين مصفوفة الطلاب
      students: (json["students"] as List?)?.map((e) => PersonModel.fromJson(e)).toList() ?? [],
      semester: (json["semester"] != null && json["semester"] is Map) ? SemesterModel.fromJson(json["semester"]) : null,
    );
  }

  int get studentsCount => students.length;

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