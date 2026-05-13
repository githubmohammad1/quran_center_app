import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/screens/shared/change_password_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'services/notification_service.dart';
import 'di/providers_setup.dart';

// Screens
import 'presentation/screens/shared/splash_screen.dart';
import 'presentation/screens/shared/login_screen.dart';
import 'presentation/screens/student/student_home_screen.dart';
import 'presentation/screens/guardian/guardian_home_screen.dart';
import 'presentation/screens/admin/manage_students_screen.dart';



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
      fontFamily: "Cairo",
    ),
    initialRoute: "/splash",
    routes: {
      "/splash": (_) => const SplashScreen(),
      "/login": (_) => const LoginScreen(),
      "/student-home": (_) => const StudentHomeScreen(),
      "/guardian-home": (_) => const GuardianHomeScreen(),
      "/change-password": (_) => const ChangePasswordScreen(),
      "/admin-home": (_) => const ManageStudentsScreen(),
    },

  
  ),
);
}
}
