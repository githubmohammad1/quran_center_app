import 'person_model.dart';
import 'semester_model.dart';

class NotificationModel {
  final int id;
  final PersonModel? student;
  final String title;
  final String message;
  final String category; // MEMORIZATION, TEST, ATTENDANCE, SUCCESS
  final int? sourceObjectId;
  final SemesterModel? semester;
  final String createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    this.student,
    required this.title,
    required this.message,
    required this.category,
    this.sourceObjectId,
    this.semester,
    required this.createdAt,
    required this.isRead,
  });

  static int _parseId(Map<String, dynamic> json) {
    final rawId = json["id"] ?? json["pk"] ?? json["notification_id"];
    if (rawId is int) return rawId;
    if (rawId is String) return int.tryParse(rawId) ?? 0;
    return 0;
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _parseId(json),
      student: (json["student"] != null && json["student"] is Map) 
          ? PersonModel.fromJson(json["student"] as Map<String, dynamic>) 
          : null,
      title: json["title"] ?? "",
      message: json["message"] ?? "",
      category: json["category"] ?? "",
      sourceObjectId: json["source_object_id"],
      semester: (json["semester"] != null && json["semester"] is Map) 
          ? SemesterModel.fromJson(json["semester"] as Map<String, dynamic>) 
          : null,
      createdAt: json["created_at"] ?? "",
      isRead: json["is_read"] ?? false,
    );
  }

  // 🚀 إضافة هندسية: تمكين التسييل لدعم ميزة قراءة الإشعارات غير المتصلة بالإنترنت
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "student": student?.toJson(),
      "title": title,
      "message": message,
      "category": category,
      "source_object_id": sourceObjectId,
      "semester": semester?.toJson(),
      "created_at": createdAt,
      "is_read": isRead,
    };
  }
}
