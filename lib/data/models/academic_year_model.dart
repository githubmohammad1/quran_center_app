class AcademicYearModel {
  final int id;
  final String name;
  final bool isActive;

  AcademicYearModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      id: json["id"],
      name: json["name"],
      isActive: json["is_active"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "is_active": isActive,
    };
  }
}
