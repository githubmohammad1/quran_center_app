import 'user_model.dart';

class PersonModel {
  final int id;
  final String fullName;
  final String role;
  final bool isActive;
  final String? parentPhone;
  final UserModel? user; // التعديل هنا

  PersonModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.parentPhone,
    this.user,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json["id"],
      fullName: json["full_name"] ?? "بدون اسم",
      role: json["role"] ?? "student",
      isActive: json["is_active"] ?? true,
      parentPhone: json["parent_phone"],
      user: json["user"] != null ? UserModel.fromJson(json["user"]) : null, // التعديل هنا
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "full_name": fullName,
      "role": role,
      "is_active": isActive,
      "parent_phone": parentPhone,
      "user": user?.toJson(),
    };
  }
}