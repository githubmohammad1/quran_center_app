import 'package:flutter/material.dart';
import '../../data/models/halqa_model.dart';
import '../../data/models/person_model.dart';
import '../../data/repositories/teacher_repository.dart';

class TeacherProvider extends ChangeNotifier {
  final TeacherRepository _repo = TeacherRepository();

  List<HalqaModel> myHalqas = [];
  List<PersonModel> currentHalqaStudents = [];
// 🌟 متغيرات الإحصائيات 
  Map<String, dynamic> dashboardStats = {
    "total_pages_memorized": 0,
    "total_points": 0,
    "total_parts_tested": 0,
    "students_count": 0,
  };
  bool loading = false;
  String? error;
  // جلب الإحصائيات
  Future<void> loadDashboardData() async {
    try {
      loading = true; error = null; notifyListeners();
      
      // جلب الحلقات والإحصائيات بالتوازي لتوفير الوقت
      final results = await Future.wait([
        _repo.getMyHalqas(),
        _repo.getTeacherStats(),
      ]);

      myHalqas = results[0] as List<HalqaModel>;
      dashboardStats = results[1] as Map<String, dynamic>;

      loading = false; notifyListeners();
    } catch (e) {
      loading = false; error = e.toString(); notifyListeners();
    }
  }

  Future<void> loadMyHalqas() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      myHalqas = await _repo.getMyHalqas();

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
    }
  }
  // الدالة المعدلة للتسميع (نرسل Grade)
   // الدالة المعدلة للتسميع (نرسل Grade)
  Future<bool> addMemorization(Map<String, dynamic> data) async {
    try { 
      await _repo.addMemorization(data); 
      return true; 
    } 
    catch (e) { 
      error = e.toString(); notifyListeners(); return false; 
    }
  } 
  
  
   // 🌟 جلب طلاب حلقة معينة، وسنقوم بترتيبهم في الـ UI أو هنا (نفترض أن السيرفر يُرجع بياناتهم)
  Future<void> loadHalqaStudents(int halqaId) async {
    try {
      loading = true; notifyListeners();
      currentHalqaStudents = await _repo.getHalqaStudents(halqaId);
      // ملاحظة: إذا أردت الترتيب حسب التقدم، يفضل أن نمرر StudentProgress معهم في الجانغو. 
      // بروتوتايب: نعرضهم الآن كما يأتوا من السيرفر.
      loading = false; notifyListeners();
    } catch (e) {
      loading = false; notifyListeners();
    }
  }
  Future<bool> addAttendance(Map<String, dynamic> data) async {
    try {
      await _repo.addAttendance(data);
      return true;
    } catch (e) {
      error = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    }
  }


  // Future<bool> addTest(Map<String, dynamic> data) async {
  //   try {
  //     await _repo.addTest(data);
  //     return true;
  //   } catch (e) {
  //     error = e.toString().replaceAll("Exception: ", "");
  //     notifyListeners();
  //     return false;
  //   }
  // }
}