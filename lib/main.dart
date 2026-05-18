import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quran_center_app/data/models/halqa_model.dart';

import 'package:quran_center_app/presentation/screens/admin/admin_tests_screen.dart';
import 'package:quran_center_app/presentation/screens/admin/manage_attendance_screen.dart';
import 'package:quran_center_app/presentation/screens/admin/manage_halqas_screen.dart';
import 'package:quran_center_app/presentation/screens/admin/manage_students_screen.dart';
import 'package:quran_center_app/presentation/screens/shared/profile_screen.dart';
import 'package:quran_center_app/presentation/screens/student/student_attendance_screen.dart';
import 'package:quran_center_app/presentation/screens/student/student_notifications_screen.dart';
import 'package:quran_center_app/presentation/screens/student/student_progress_screen.dart';
import 'package:quran_center_app/presentation/screens/student/student_tests_screen.dart';
import 'package:quran_center_app/presentation/screens/teacher/StudentQRScreen.dart';
import 'package:quran_center_app/presentation/screens/teacher/TeacherAddMemorizationScreen.dart';
import 'package:quran_center_app/presentation/screens/teacher/TeacherHalqaStudentsScreen.dart';
import 'package:quran_center_app/presentation/screens/teacher/TeacherQRScannerScreen.dart';
import 'package:quran_center_app/presentation/screens/teacher/teacher_attendis_sceen.dart';
import 'package:quran_center_app/presentation/screens/teacher/teacher_home_screen.dart';
import 'firebase_options.dart';

import 'services/notification_service.dart';
import 'di/providers_setup.dart';

// Screens
import 'presentation/screens/shared/splash_screen.dart';
import 'presentation/screens/shared/login_screen.dart';
import 'presentation/screens/shared/change_password_screen.dart';
import 'presentation/screens/student/student_home_screen.dart';
import 'presentation/screens/guardian/guardian_home_screen.dart';
import 'presentation/screens/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    await NotificationService.initialize();
  }

  runApp(const QuranCenterApp());
}

class QuranCenterApp extends StatelessWidget {
  const QuranCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ProvidersSetup.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Quran Center",
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          fontFamily: "Cairo", // تأكد من إضافة خط Cairo في pubspec.yaml
        ),
        initialRoute: "/splash",
        routes: {
          "/admin-halqas": (_) => const ManageHalqasScreen(), // (نصنعها لاحقاً)
"/admin-attendance": (_) => const AdminAttendanceScreen(), // (نصنعها لاحقاً)
"/admin-tests": (_) => const AdminTestsScreen(),
"/profile": (_) => const ProfileScreen(), // لا تنسى شاشة البروفايل
          "/admin-students": (_) => const ManageStudentsScreen(),
          "/splash": (_) => const SplashScreen(),
          "/login": (_) => const LoginScreen(),
          "/change-password": (_) => const ChangePasswordScreen(),
          "/student-home": (_) => const StudentDashboard(),
          "/guardian-home": (_) => const GuardianHomeScreen(),
          "/admin-home": (_) => const AdminDashboard(),
          
          "/teacher-home": (_) => const TeacherDashboard(),



  "/student-attendance": (context) => const StudentAttendanceScreen(),
  "/student-tests": (context) => const StudentTestsScreen(),
  "/student-notifications": (context) => const StudentNotificationsScreen(),
  "/student-progress": (context) => const StudentProgressScreen(),


 "/teacher-dashboard": (context) => const TeacherDashboard(),
  "/teacher-halqa-students": (context) {
    final halqa = ModalRoute.of(context)!.settings.arguments as HalqaModel;
    return TeacherHalqaStudentsScreen(halqa: halqa);
  },
"/teacher-add-memorization": (context) {
  // جلب الـ arguments مع التحقق من عدم كونها فارغة وتأمين الـ Cast
  final args = ModalRoute.of(context)?.settings.arguments;
  
  if (args is Map<String, dynamic>) {
    return MemorizationSessionSheet(args: args);
  }
  
  // سد فجوة الخطأ: إرجاع واجهة فارغة أو شاشة خطأ بدلاً من انهيار التطبيق بالكامل
  return const Scaffold(
    body: Center(child: Text("خطأ في نقل البيانات المعمارية للشاشة")),
  );
},


  "/teacher-attendance": (context) => const TeacherAttendanceScreen(),
  // "/teacher-add-test": (context) => const TeacherAddTestScreen(),
  "/teacher-scan-qr": (context) => const TeacherQRScannerScreen(),
"/teacher-student-qr": (context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  return StudentQRScreen(student: args["student"]);
},





        },
      ),
    );
  }
}