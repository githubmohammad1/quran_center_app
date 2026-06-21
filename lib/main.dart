// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quran_center_app/main_navigator_key.dart';
import 'package:quran_center_app/presentation/screens/admin/manage_staff_screen.dart';
import 'package:quran_center_app/presentation/screens/guardian/children_list_screen.dart';
import 'package:quran_center_app/presentation/screens/guardian/guardian_child_attendance_screen.dart';
import 'package:quran_center_app/presentation/screens/guardian/guardian_child_memorization_screen.dart';
import 'package:quran_center_app/presentation/screens/guardian/guardian_child_tests_screen.dart';
import 'package:quran_center_app/presentation/screens/shared/leaderboard_test_screen.dart';

import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'di/providers_setup.dart';

// Screens
import 'presentation/screens/shared/splash_screen.dart';
import 'presentation/screens/shared/login_screen.dart';
import 'presentation/screens/shared/change_password_screen.dart';
import 'presentation/screens/shared/profile_screen.dart';

import 'presentation/screens/student/student_home_screen.dart';
import 'presentation/screens/student/student_attendance_screen.dart';
import 'presentation/screens/student/student_tests_screen.dart';
import 'presentation/screens/student/student_notifications_screen.dart';
import 'presentation/screens/student/student_progress_screen.dart';

import 'presentation/screens/guardian/guardian_home_screen.dart';

import 'presentation/screens/admin/admin_dashboard.dart';
import 'presentation/screens/admin/manage_academic_screen.dart';
import 'presentation/screens/admin/manage_halqas_screen.dart';
import 'presentation/screens/admin/manage_attendance_screen.dart';
import 'presentation/screens/admin/manage_memorization_screen.dart';
import 'presentation/screens/admin/manage_students_screen.dart';
import 'presentation/screens/admin/admin_tests_screen.dart';
import 'presentation/screens/admin/admin_notifications_screen.dart';

import 'presentation/screens/teacher/teacher_home_screen.dart';
import 'presentation/screens/teacher/TeacherQRScannerScreen.dart';
import 'presentation/screens/teacher/teacher_attendis_sceen.dart';
import 'presentation/screens/teacher/TeacherHalqaStudentsScreen.dart';
import 'presentation/screens/teacher/TeacherAddMemorizationScreen.dart';

import 'presentation/screens/shared/student_qr_card_screen.dart';
import 'data/models/person_model.dart';
import 'data/models/halqa_model.dart';

class AppResetWrapper extends StatefulWidget {
  final Widget child;
  const AppResetWrapper({super.key, required this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_AppResetWrapperState>()?.restartApp();
  }

  @override
  State<AppResetWrapper> createState() => _AppResetWrapperState();
}

class _AppResetWrapperState extends State<AppResetWrapper> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey(); // توليد مفتاح فريد يدمر ويصفي الذاكرة القديمة فوراً
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // String? token = await FirebaseMessaging.instance.getToken();
  // print("🚀 FCM TOKEN: $token");

  runApp(const AppResetWrapper(child: QuranCenterApp()));

  // التعديل الهندسي الذكي: الاستدعاء مباشرة بعد الـ runApp لضمان جاهزية السياق (Context Setup)
  await NotificationService.initialize(navigatorKey);
}

class QuranCenterApp extends StatefulWidget {
  const QuranCenterApp({super.key});

  @override
  State<QuranCenterApp> createState() => _QuranCenterAppState();
}

class _QuranCenterAppState extends State<QuranCenterApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // تسجيل المراقب في نظام تشغيل فلاتر
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // إزالة المراقب عند تدمير الـ Widget لمنع تسريب الذاكرة (Memory Leaks)
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 🧹 التطهير التلقائي: عندما يعود المستخدم للتطبيق من الخلفية فوراً
    if (state == AppLifecycleState.resumed) {
      // print(
      //   "🔄 [LIFECYCLE] التطبيق عاد للواجهة النشطة. جاري مسح الإشعارات وتصفير الشارات...",
      // );
      NotificationService.clearAllNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ProvidersSetup.providers, //
      child: MaterialApp(
        navigatorKey: navigatorKey, //
        debugShowCheckedModeBanner: false,
        title: "Quran Center", //
        theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: "Cairo"), //
        initialRoute: "/splash", //
        routes: {
          "/guardian-home": (context) => const GuardianHomeScreen(),
          // الراوت الجديد الموجه للوحة تحكم الابن المختار
          "/guardian-child-dashboard": (context) =>
              const GuardianChildDashboardScreen(),

          // شاشات التفاصيل الفرعية للابن
          "/guardian-child-attendance": (context) =>
              const GuardianChildAttendanceScreen(),
          "/guardian-child-tests": (context) =>
              const GuardianChildTestsScreen(),
          "/guardian-child-progress": (context) =>
              const GuardianChildMemorizationScreen(),

          "/loadr_screen": (_) =>
              const LeaderboardTestScreen(), // شاشة تحميل عامة يمكن إعادة استخدامها
          // ============================
          // 1) Auth & Shared
          // ============================
          "/splash": (_) => const SplashScreen(),
          "/login": (_) => const LoginScreen(),
          "/change-password": (_) => const ChangePasswordScreen(),
          "/profile": (_) => const ProfileScreen(),

          // ============================
          // 2) Admin
          // ============================
          "/admin-home": (_) => const AdminDashboard(),
          "/admin-halqas": (_) => const ManageHalqasScreen(),
          "/admin-academic": (_) => const ManageAcademicScreen(),
          "/admin-attendance": (_) => const AdminAttendanceScreen(),
          "/admin-memorization": (_) => const ManageMemorizationScreen(),
          "/admin-scan-qr": (_) =>
              const TeacherQRScannerScreen(isAdminMode: true),
          "/admin-students": (_) => const ManageStudentsScreen(),
          "/admin-tests": (_) => AdminTestsScreen(),
          "/admin-notifications": (_) => const AdminNotificationsScreen(),

          // ============================
          // 3) Student & Guardian
          // ============================
          "/student-home": (_) => const StudentDashboard(),
          "/student-attendance": (_) => const StudentAttendanceScreen(),
          "/student-tests": (_) => const StudentTestsScreen(),
          "/student-notifications": (_) => const StudentNotificationsScreen(),
          "/student-progress": (_) => const StudentProgressScreen(),

          // ============================
          // 4) Teacher
          // ============================
          "/teacher-home": (_) => const TeacherDashboard(),
          "/teacher-dashboard": (_) => const TeacherDashboard(),
          "/teacher-scan-qr": (_) => const TeacherQRScannerScreen(),
          "/teacher-attendance": (_) => const TeacherAttendanceScreen(),
          "/teacher-halqa-students": (context) {
            final halqa =
                ModalRoute.of(context)!.settings.arguments as HalqaModel;
            return TeacherHalqaStudentsScreen(halqa: halqa);
          },

          // ============================
          // 5) Shared Routes
          // ============================
          "/shared-student-qr": (context) {
            final args = ModalRoute.of(context)?.settings.arguments;

            if (args is PersonModel) {
              return StudentQRCardScreen(student: args);
            }

            return const Scaffold(
              body: Center(child: Text("خطأ: لم يتم تمرير بيانات الطالب")),
            );
          },

          "/shared-add-memorization": (context) {
            final args = ModalRoute.of(context)?.settings.arguments;

            if (args is Map<String, dynamic>) {
              return MemorizationSessionSheet(args: args);
            }

            return const Scaffold(
              body: Center(child: Text("خطأ في تمرير بيانات التسميع")),
            );
          },

          "/admin-staff": (_) => const ManageStaffScreen(),
        },
      ),
    );
  }
}
