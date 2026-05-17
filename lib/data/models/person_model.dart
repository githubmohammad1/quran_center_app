import 'user_model.dart';

class PersonModel {
  final int id;
  final String fullName;
  final String role; // student, teacher, supervisor
  final bool isActive;
  final String? parentPhone;
  final UserModel? user; 

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
      // أمان في حال أرجع السيرفر الـ user كـ ID (رقم) بدلاً من Object
      user: (json["user"] != null && json["user"] is Map) 
          ? UserModel.fromJson(json["user"]) 
          : null, 
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