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

  /// يجلب البروفايل أولاً ثم يستخدم بياناته لطلب بقية الموارد.
  Future<void> loadAll() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      profile = await _repo.getProfile();

      // إذا لم يوجد بروفايل، نوقف العملية
      if (profile == null) {
        loading = false;
        error = "لم يتم العثور على ملف المستخدم";
        notifyListeners();
        return;
      }

      final studentName = profile!.fullName;
      final studentId = profile!.id;

      // جلب البيانات بالتوازي
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
      error = e.toString();
      notifyListeners();
    }
  }

  /// تحديث جزء واحد (مثال: بعد إضافة حضور) لإعادة تحميل الحضور فقط
  Future<void> refreshAttendance() async {
    if (profile == null) return;
    try {
      final studentName = profile!.fullName;
      attendance = await _repo.getAttendance(studentName);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
