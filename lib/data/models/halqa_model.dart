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
    // 🛠️ تصحيح الجودة: فحص ومعالجة مصفوفة الطلاب بأمان تلم للتخلص من مشكلة الـ Type Casting
    var studentsList = json["students"];
    List<PersonModel> parsedStudents = [];
    if (studentsList != null && studentsList is List) {
      parsedStudents = studentsList.map((e) => PersonModel.fromJson(e as Map<String, dynamic>)).toList();
    }

    return HalqaModel(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      teacher: (json["teacher"] != null && json["teacher"] is Map) 
          ? PersonModel.fromJson(json["teacher"] as Map<String, dynamic>) 
          : null,
      students: parsedStudents,
      semester: (json["semester"] != null && json["semester"] is Map) 
          ? SemesterModel.fromJson(json["semester"] as Map<String, dynamic>) 
          : null,
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