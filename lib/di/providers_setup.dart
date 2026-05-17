import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:quran_center_app/presentation/providers/admin_providers.dart';
import 'package:quran_center_app/presentation/providers/guardian_providers.dart';
import 'package:quran_center_app/presentation/providers/student_providers.dart';

// استدعاء جميع الـ Providers
import '../presentation/providers/auth_provider.dart';

import '../presentation/providers/teacher_provider.dart';

import '../presentation/providers/general_provider.dart';

class ProvidersSetup {
  static List<SingleChildWidget> get providers => [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GeneralProvider()), // للسور والصفحات (مهم جداً للجميع)
        
        // المزودات الخاصة بالصلاحيات (يتم استدعاء بياناتها من داخل الشاشات حسب المستخدم)
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => GuardianProvider()),
      ];
}