import 'academic_year_model.dart';

class SemesterModel {
  final int id;
  final AcademicYearModel? year;
  final String name; // summer, winter
  final String startDate;
  final String endDate;
  final bool isActive;

  SemesterModel({
    required this.id,
    this.year,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      id: json["id"],
      year: (json["year"] != null && json["year"] is Map) ? AcademicYearModel.fromJson(json["year"]) : null,
      name: json["name"] ?? "",
      startDate: json["start_date"] ?? "",
      endDate: json["end_date"] ?? "",
      isActive: json["is_active"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "year": year?.toJson(),
      "name": name,
      "start_date": startDate,
      "end_date": endDate,
      "is_active": isActive,
    };
  }
}