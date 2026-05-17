import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 650;

    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة تحكم الإدارة"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            onPressed: () => Navigator.pushNamed(context, "/profile"),
          )
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: GridView.count(
              crossAxisCount: isWide ? 3 : 2,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _dashboardCard(
                  context,
                  title: "الطلاب",
                  icon: Icons.school,
                  color: Colors.blue,
                  route: "/admin-students",
                ),
                _dashboardCard(
                  context,
                  title: "الحلقات",
                  icon: Icons.group_work,
                  color: Colors.green,
                  route: "/admin-halqas",
                ),
                _dashboardCard(
                  context,
                  title: "الحضور",
                  icon: Icons.co_present,
                  color: Colors.orange,
                  route: "/admin-attendance",
                ),
                _dashboardCard(
                  context,
                  title: "الاختبارات",
                  icon: Icons.quiz,
                  color: Colors.purple,
                  route: "/admin-tests",
                ),
                _dashboardCard(
                  context,
                  title: "الإشعارات",
                  icon: Icons.notifications,
                  color: Colors.red,
                  route: "/admin-notifications",
                ),
                _dashboardCard(
                  context,
                  title: "الإعدادات",
                  icon: Icons.settings,
                  color: Colors.grey,
                  route: "/admin-settings",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.7),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
