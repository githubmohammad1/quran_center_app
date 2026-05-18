import 'user_model.dart';

class PersonModel {
  final int id;
  final String fullName;
  final String role; // student, teacher, supervisor
  final bool isActive;
  final String? parentPhone;
  final String? qrCode; // 🛠️ تم الحقن المعتمد: لدعم استقبال رابط الـ QR Code المطلق من السيرفر
  final UserModel? user; 

  PersonModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.parentPhone,
    this.qrCode,
    this.user,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json["id"] ?? 0,
      fullName: json["full_name"] ?? "بدون اسم",
      role: json["role"] ?? "student",
      isActive: json["is_active"] ?? true,
      parentPhone: json["parent_phone"],
      qrCode: json["qr_code"], // 🛠️ استقبال الرابط المطلق الجاهز للعرض بداخل واجهة فلاتر
      // تحصين معالج الـ User Object لمنع انهيار التطبيق
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
      "is_active": isActive,
      "parent_phone": parentPhone,
      "qr_code": qrCode, // تصدير الـ QR لضمان الحفظ المحلي المتكامل
      "user": user?.toJson(),
    };
  }
}