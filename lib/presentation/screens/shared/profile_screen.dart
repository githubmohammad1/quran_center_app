import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/auth_provider.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _getArabicRole(String role) {
    switch (role) {
      case 'student': return 'طالب';
      case 'teacher': return 'أستاذ';
      case 'supervisor': return 'مشرف / إدارة';
      case 'guardian': return 'ولي أمر';
      default: return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("الملف الشخصي"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: "تسجيل الخروج",
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, "/login", (r) => false);
            },
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: user == null
                ? const Text("لا يوجد مستخدم مسجل")
                : Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.indigo,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          _getArabicRole(user.role),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.indigoAccent,
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(Icons.phone, color: Colors.indigo),
                          title: const Text("رقم الهاتف"),
                          subtitle: Text(user.user?.phone ?? 'غير متوفر', style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, "/change-password"),
                          icon: const Icon(Icons.lock_reset),
                          label: const Text("تغيير كلمة المرور", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}