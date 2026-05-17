import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/auth_provider.dart';
import 'package:quran_center_app/presentation/providers/general_provider.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
    _slide = Tween(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));

    _anim.forward();

    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    final auth = context.read<AuthProvider>();

    final ok = await auth.tryAutoLogin();

    if (!mounted) return;

    if (!ok) {
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }

    context.read<GeneralProvider>().loadGeneralData();

    final role = auth.user?.role;

    switch (role) {
      case "student":
        Navigator.pushReplacementNamed(context, "/student-home");
        break;
      case "teacher":
        Navigator.pushReplacementNamed(context, "/teacher-home");
        break;
      case "supervisor":
        Navigator.pushReplacementNamed(context, "/admin-home");
        break;
      case "guardian":
        Navigator.pushReplacementNamed(context, "/guardian-home");
        break;
      default:
        Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // -----------------------------------
          // الخلفية الإسلامية
          // -----------------------------------
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F5132),
                  Color(0xFF198754),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // زخرفة إسلامية خفيفة
          Positioned(
            top: -60,
            left: -40,
            child: Opacity(
              opacity: 0.12,
              child: Image(
                image: AssetImage("assets/patterns/islamic_pattern.png"),
                width: 300,
              ),
            ),
          ),

          Positioned(
            bottom: -40,
            right: -30,
            child: Opacity(
              opacity: 0.12,
              child: Image(
                image: AssetImage("assets/patterns/islamic_pattern.png"),
                width: 260,
              ),
            ),
          ),

          // -----------------------------------
          // المحتوى المتحرك (Fade + Slide)
          // -----------------------------------
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // أيقونة المصحف
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "مركز تعليم القرآن",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            "نسأل الله الإخلاص والقبول",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),

                          const SizedBox(height: 30),

                          const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
