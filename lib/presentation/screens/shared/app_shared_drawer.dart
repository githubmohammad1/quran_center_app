import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:quran_center_app/main_navigator_key.dart';
import 'package:quran_center_app/presentation/providers/auth_provider.dart';

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
    // الاستماع الفوري لحالة الصلاحيات والتبديل
    final auth = context.watch<AuthProvider>();
    final userModel = auth.user;
    final currentRole = auth.currentRole;

    // Edge Case Guard: إذا لم يكن هناك مستخدم مسجل، نعيد حاوية فارغة بأمان
    if (userModel == null) return const SizedBox.shrink();

    return Drawer(
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
              userModel.user?.phone ?? "", // جلب الهاتف بأمان نل-سيف
              style: const TextStyle(fontFamily: "Cairo", fontSize: 13),
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.blueGrey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.indigo),
            ),
          ),

          // عنوان جانبي توضيحي لأقسام التبديل
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "اللوحات والمقامات المتاحة لحسابك",
                style: TextStyle(
                  color: Colors.grey[600],
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  child: ListTile(
                    selected: isCurrentActive,
                    selectedTileColor: (config['color'] as Color).withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    leading: Icon(
                      config['icon'] as IconData,
                      color: isCurrentActive ? config['color'] as Color : Colors.grey[600],
                    ),
                    title: Text(
                      config['title'] as String,
                      style: TextStyle(
                        fontFamily: "Cairo",
                        fontWeight: isCurrentActive ? FontWeight.bold : FontWeight.w500,
                        color: isCurrentActive ? config['color'] as Color : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      config['subtitle'] as String,
                      style: const TextStyle(fontSize: 11, fontFamily: "Cairo"),
                    ),
                    trailing: isCurrentActive
                        ? Icon(Icons.check_circle, color: config['color'] as Color, size: 20)
                        : const Icon(Icons.arrow_back_ios, size: 12, color: Colors.grey),
                    onTap: isCurrentActive 
                        ? () => Navigator.pop(context) // إغلاق القائمة فقط إذا كان الدور نشطاً
                        : () {
                            Navigator.pop(context);

                            WidgetsBinding.instance.addPostFrameCallback((_) async {
                              await Future.delayed(const Duration(milliseconds: 100));
                              if (!context.mounted) return;

                              // تنفيذ التبديل
                              context.read<AuthProvider>().switchRole(roleKey);

                              // الانتقال وتصفير الشاشات السابقة
                              Navigator.pushNamedAndRemoveUntil(
                                context, 
                                config['route'] as String, 
                                (route) => false,
                              );
                            });
                          },
                  ),
                );
              },
            ),
          ),

          const Divider(),

          // 3. قسم التحكم بالنظام (تسجيل الخروج) - تم إصلاحه هندسياً لمنع التعليق وعزل الـ Context
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "تسجيل الخروج من المنظومة",
              style: TextStyle(
                color: Colors.red,
                fontFamily: "Cairo",
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              // أخذ نسخة من الـ AuthProvider قبل إغلاق الواجهة وحذف الـ Context
              final authProvider = context.read<AuthProvider>();

              // 1. إغلاق الـ Drawer فوراً لحماية أنميشن الحركة
              Navigator.pop(context);

              // 2. استدعاء دالة الخروج وانتظار السيرفر تماماً لتعطيل التوكن
              await authProvider.logout();

              // 3. الحل الهندسي النظيف: الانتقال الفوري لصفحة الدخول عبر الـ navigatorKey العالمي
              // لمنع مشكلة تجمد الشاشة والـ Context المنفصل
              if (navigatorKey.currentState != null) {
                navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  "/login",
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}