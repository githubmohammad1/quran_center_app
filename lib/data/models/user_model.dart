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
      id: json["id"],
      phone: json["phone"] ?? "",
      fcmToken: json["fcm_token"],
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