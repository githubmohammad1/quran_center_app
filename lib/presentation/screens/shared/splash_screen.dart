import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // عرض الشعار لمدة قصيرة
    await Future.delayed(const Duration(seconds: 1));

    final auth = context.read<AuthProvider>();

    // محاولة تسجيل الدخول تلقائيًا
    final ok = await auth.tryAutoLogin();

    if (!mounted) return;

    if (!ok) {
      // لم يتم تسجيل الدخول → الذهاب للّوجين
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }

    // إذا نجح تسجيل الدخول → نحدد الدور
    final role = auth.user?.role;

    switch (role) {
      case "student":
        Navigator.pushReplacementNamed(context, "/student-home");
        break;

      case "guardian":
        Navigator.pushReplacementNamed(context, "/guardian-home");
        break;

      case "admin":
      case "teacher":
      case "supervisor":
        Navigator.pushReplacementNamed(context, "/admin-home");
        break;

      default:
        Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Text(
          "Quran Center",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
