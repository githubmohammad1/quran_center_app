import 'package:flutter/material.dart';
import '../../data/models/person_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/memorization_session_model.dart';
import '../../data/models/quran_test_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/student_progress_model.dart';
import '../../data/repositories/student_repository.dart';

class StudentProvider extends ChangeNotifier {
  final StudentRepository _repo = StudentRepository();

  PersonModel? profile;
  List<AttendanceModel> attendance = [];
  List<MemorizationSessionModel> memorization = [];
  List<QuranTestModel> tests = [];
  List<NotificationModel> notifications = [];
  StudentProgressModel? progress;

  bool loading = false;
  String? error;

  Future<void> loadAll() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      profile = await _repo.getProfile();

      if (profile == null) {
        loading = false;
        error = "لم يتم العثور على ملف المستخدم";
        notifyListeners();
        return;
      }

      final studentName = profile!.fullName;
      final studentId = profile!.id;

      final results = await Future.wait([
        _repo.getAttendance(studentName),
        _repo.getMemorizationSessions(studentName),
        _repo.getTests(studentId),
        _repo.getNotifications(),
        _repo.getProgress(),
      ]);

      attendance = results[0] as List<AttendanceModel>;
      memorization = results[1] as List<MemorizationSessionModel>;
      tests = results[2] as List<QuranTestModel>;
      notifications = results[3] as List<NotificationModel>;
      progress = results[4] as StudentProgressModel?;

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
    }
  }

  // ✨ دالة جديدة لجعل الإشعار مقروءاً
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _repo.markNotificationRead(notificationId);
      // تحديث الحالة محلياً لتغيير لون الإشعار في الواجهة مباشرة
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // بما أن الحقول final، نستبدل الكائن في القائمة بكائن جديد يحمل isRead = true
        notifications[index] = NotificationModel(
          id: notifications[index].id,
          student: notifications[index].student,
          title: notifications[index].title,
          message: notifications[index].message,
          category: notifications[index].category,
          sourceObjectId: notifications[index].sourceObjectId,
          semester: notifications[index].semester,
          createdAt: notifications[index].createdAt,
          isRead: true, // هنا التغيير
        );
        notifyListeners();
      }
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }
}