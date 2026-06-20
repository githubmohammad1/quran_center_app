import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:quran_center_app/main_navigator_key.dart';
import 'package:quran_center_app/presentation/providers/auth_provider.dart';
import 'package:quran_center_app/presentation/screens/shared/change_password_screen.dart'; // 🛠️ تأكد من مسار الاستيراد الصحيح لشاشتك

class AppSharedDrawer extends StatelessWidget {
  const AppSharedDrawer({super.key});

  // مصفوفة تعريفية لترجمة الأدوار تقنياً وبصرياً
  Map<String, dynamic> _getRoleConfig(String role) {
    switch (role) {
      case 'admin':
        return {
          'title': "لوحة الإدارة العامة",
          'subtitle': 'إدارة المنظومة، الحسابات، والتقارير',
          'icon': Icons.admin_panel_settings,
          'color': Colors.indigo,
          'route': '/admin-home',
        };
      case 'supervisor':
        return {
          'title': "لوحة الموجه الإداري",
          'subtitle': 'متابعة الحلقات والخطط التعليمية',
          'icon': Icons.assignment_ind,
          'color': Colors.teal,
          'route': '/supervisor-home',
        };
      case 'teacher':
        return {
          'title': "لوحة الأستاذ / المحفّظ",
          'subtitle': 'إدارة التسميع، الحضور، وحلقتك',
          'icon': Icons.menu_book,
          'color': Colors.orange,
          'route': '/teacher-home',
        };
      case 'student':
        return {
          'title': 'لوحة الطالب القرآني',
          'subtitle': 'متابعة حفظك، درجاتك، وإشعاراتك',
          'icon': Icons.school,
          'color': Colors.blue,
          'route': '/student-home',
        };
      case 'guardian':
        return {
          'title': 'لوحة ولي الأمر',
          'subtitle': 'مراقبة حضور وتقدم أبنائك المربوطين',
          'icon': Icons.family_restroom,
          'color': Colors.green,
          'route': '/guardian-home',
        };
      default:
        return {
          'title': 'لوحة تحكم عامة',
          'subtitle': 'تصفح المنظومة',
          'icon': Icons.person,
          'color': Colors.grey,
          'route': '/home',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userModel = auth.user;
    final currentRole = auth.currentRole;

    if (userModel == null) return const SizedBox.shrink();

    return Drawer(
      backgroundColor: Colors.grey.shade50,
      child: Column(
        children: [
          // 1. الهيدر الموحد لبيانات الحساب الشخصي
          UserAccountsDrawerHeader(
            accountName: Text(
              userModel.fullName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: "Cairo",
              ),
            ),
            accountEmail: Text(
              userModel.user?.phone ?? "",
              style: const TextStyle(fontFamily: "Cairo", fontSize: 13),
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.blueGrey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
                ],
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.indigo),
              ),
            ),
          ),

          // عنوان جانبي توضيحي لأقسام التبديل بين المقامات التربوية
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "اللوحات والمقامات المتاحة لحسابك",
                style: TextStyle(
                  color: Colors.blueGrey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Cairo",
                ),
              ),
            ),
          ),

          // 2. البناء الديناميكي للأدوار المتاحة للمستخدم فعلياً من السيرفر
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: userModel.roles.length,
              itemBuilder: (context, index) {
                final roleKey = userModel.roles[index];
                final config = _getRoleConfig(roleKey);
                final isCurrentActive = currentRole == roleKey;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCurrentActive ? (config['color'] as Color).withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrentActive ? (config['color'] as Color).withOpacity(0.3) : Colors.grey.shade200,
                        width: isCurrentActive ? 1.5 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                      leading: CircleAvatar(
                        backgroundColor: isCurrentActive 
                            ? (config['color'] as Color).withOpacity(0.2) 
                            : Colors.grey.shade100,
                        radius: 18,
                        child: Icon(
                          config['icon'] as IconData,
                          color: isCurrentActive ? config['color'] as Color : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        config['title'] as String,
                        style: TextStyle(
                          fontFamily: "Cairo",
                          fontSize: 14,
                          fontWeight: isCurrentActive ? FontWeight.bold : FontWeight.w600,
                          color: isCurrentActive ? config['color'] as Color : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        config['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 11, 
                          fontFamily: "Cairo",
                          color: isCurrentActive ? (config['color'] as Color).withOpacity(0.8) : Colors.black54,
                        ),
                      ),
                      trailing: isCurrentActive
                          ? Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: (config['color'] as Color).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check, color: config['color'] as Color, size: 16),
                            )
                          : Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
                      onTap: isCurrentActive 
                          ? () => Navigator.pop(context)
                          : () {
                              Navigator.pop(context);
                              WidgetsBinding.instance.addPostFrameCallback((_) async {
                                await Future.delayed(const Duration(milliseconds: 100));
                                if (!context.mounted) return;

                                context.read<AuthProvider>().switchRole(roleKey);

                                Navigator.pushNamedAndRemoveUntil(
                                  context, 
                                  config['route'] as String, 
                                  (route) => false,
                                );
                              });
                            },
                    ),
                  ),
                );
              },
            ),
          ),

          // خط فاصل نقي ومعزول يفصل بين الأدوار وبين أدوات التحكم بالحساب
          const Divider(height: 1, thickness: 1),

          // 🛠️ 3. قسم أدوات إدارة الحساب (تغيير كلمة المرور)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 4.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueGrey.withOpacity(0.15)),
              ),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.lock_reset_rounded, color: Colors.blueGrey),
                title: const Text(
                  "تغيير كلمة المرور",
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.blueGrey.shade400),
                onTap: () {
                  // 🚀 تكتيك ملاحة آمن: إغلاق الـ Drawer أولاً لتجنب تراكم الطبقات الرسومية (Overlays)
                  Navigator.pop(context);
                  
                  // الملاحة لشاشة تغيير كلمة المرور
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                  );
                },
              ),
            ),
          ),

          // 🚀 4. إرجاع زر تسجيل الخروج لأسفل الشاشة مع "مصد أمان برميجي"
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 4.0, bottom: 4.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.15)),
              ),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "تسجيل الخروج من المنظومة",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                onTap: () async {
                  final authProvider = context.read<AuthProvider>();
                  Navigator.pop(context);
                  await authProvider.logout();

                  if (navigatorKey.currentState != null) {
                    navigatorKey.currentState!.pushNamedAndRemoveUntil(
                      "/login",
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ),

          // 🔥 المصد البرميجي الذكي (Safe Navigation Guard)
          SafeArea(
            top: false,
            bottom: true,
            child: SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? 0 : 12),
          ),
        ],
      ),
    );
  }
}