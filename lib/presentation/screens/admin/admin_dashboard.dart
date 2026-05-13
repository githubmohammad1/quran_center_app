import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("لوحة التحكم")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _item(context, "إدارة الطلاب", "/admin-students"),
          _item(context, "إدارة الحلقات", "/admin-halqas"),
          _item(context, "تسجيل الحضور", "/admin-attendance"),
          _item(context, "تسجيل الاختبارات", "/admin-tests"),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String title, String route) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
