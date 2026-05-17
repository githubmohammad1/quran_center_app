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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["id"],
      student: (json["student"] != null && json["student"] is Map) ? PersonModel.fromJson(json["student"]) : null,
      title: json["title"] ?? "",
      message: json["message"] ?? "",
      category: json["category"] ?? "",
      sourceObjectId: json["source_object_id"],
      semester: (json["semester"] != null && json["semester"] is Map) ? SemesterModel.fromJson(json["semester"]) : null,
      createdAt: json["created_at"] ?? "",
      isRead: json["is_read"] ?? false,
    );
  }
}