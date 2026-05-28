import 'user_model.dart';

class PersonModel {
  final int id;
  final String fullName;
  final String role; // الحقل القديم (أبقيناه للتوافق الرجعي)
  final List<String> roles; // 🚀 التحديث الهندسي: استقبال قائمة الأدوار بالكامل
  final bool isActive;
  final String? parentPhone;
  final String? qrCode; 
  final UserModel? user; 

  PersonModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.roles, // مضاف حديثاً
    required this.isActive,
    this.parentPhone,
    this.qrCode,
    this.user,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    // التحقق من الحقل وتحويله بأمان إلى قائمة نصوص لتجنب خطأ الـ Type Cast Exception
    var rolesFromJson = json["roles"];
    List<String> rolesList = rolesFromJson != null 
        ? List<String>.from(rolesFromJson) 
        : [json["role"] ?? "student"]; // القيمة الافتراضية إذا غاب الحقل هي الدور المفرد القديم

    return PersonModel(
      id: json["id"] ?? 0,
      fullName: json["full_name"] ?? "بدون اسم",
      role: json["role"] ?? "student",
      roles: rolesList, // 🚀 حقن القائمة المحدثة
      isActive: json["is_active"] ?? true,
      parentPhone: json["parent_phone"],
      qrCode: json["qr_code"], 
      user: (json["user"] != null && json["user"] is Map) 
          ? UserModel.fromJson(json["user"] as Map<String, dynamic>) 
          : null, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "full_name": fullName,
      "role": role,
      "roles": roles, // 🚀 تصدير قائمة الأدوار للحفظ المحلي (Secure Storage/Hive)
      "is_active": isActive,
      "parent_phone": parentPhone,
      "qr_code": qrCode, 
      "user": user?.toJson(),
    };
  }
}