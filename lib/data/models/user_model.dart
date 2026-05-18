class UserModel {
  final int id;
  final String phone;
  final String? fcmToken;

  UserModel({
    required this.id,
    required this.phone,
    this.fcmToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"] ?? 0, // 🛠️ تصحيح الجودة: تأمين المعرف الفرعي لمنع الـ Null Pointer Exception
      phone: json["phone"] ?? "", // تحصين الحقل بنص فارغ في حال غيابه
      fcmToken: json["fcm_token"], // حقل اختياري سليم منطقياً
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "phone": phone,
      "fcm_token": fcmToken,
    };
  }
}