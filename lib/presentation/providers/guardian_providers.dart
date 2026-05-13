import 'package:flutter/material.dart';
import '../../data/models/person_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/quran_test_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/student_progress_model.dart';
import '../../data/repositories/guardian_repository.dart';

class GuardianProvider extends ChangeNotifier {
  final GuardianRepository _repo = GuardianRepository();

  List<PersonModel> children = [];
  PersonModel? selectedChild;

  List<AttendanceModel> attendance = [];
  List<QuranTestModel> tests = [];
  List<NotificationModel> notifications = [];
  StudentProgressModel? progress;

  bool loading = false;
  String? error;

  Future<void> loadChildren() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      children = await _repo.getChildren();

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  /// تحميل بيانات ابن محدد. إذا لم يمرر اسم الابن، نستخدم selectedChild.fullName
  Future<void> loadChildData(int childId, {String? childName}) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      selectedChild = await _repo.getChildProfile(childId);

      final nameToSearch = childName ?? selectedChild?.fullName ?? "";

      attendance = await _repo.getChildAttendance(nameToSearch);
      tests = await _repo.getChildTests(childId);
      // notifications endpoint قد لا يكون موجودًا في GuardianApi حسب إعدادك، فنتحقق
      try {
        // إذا كانت هناك دالة في الريبو لإرجاع إشعارات الابن، استعملها
        // notifications = await _repo.getChildNotifications(childId);
      } catch (_) {
        notifications = [];
      }

      progress = await _repo.getChildProgress(nameToSearch);

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    }
  }
}
