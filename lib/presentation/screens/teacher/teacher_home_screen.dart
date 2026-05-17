import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/data/models/halqa_model.dart';
import 'package:quran_center_app/presentation/providers/auth_provider.dart';
import '../../providers/teacher_provider.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();

    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text("لوحة المعلم"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FA), Color(0xFFF1F3F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  _header(),
                  const SizedBox(height: 20),
                  _kpiCards(provider),
                  const SizedBox(height: 20),
                  _halqasSection(provider),
                  const SizedBox(height: 20),
                  _quickActions(context),
                ],
              ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.person, size: 40, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "أهلاً أستاذنا الكريم",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- KPIs ----------------
  Widget _kpiCards(TeacherProvider provider) {
    final stats = provider.dashboardStats;

    return Row(
      children: [
        Expanded(child: _kpi("الصفحات", stats["total_pages_memorized"], Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _kpi("الأجزاء", stats["total_parts_tested"], Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _kpi("الطلاب", stats["students_count"], Colors.blue)),
      ],
    );
  }

  Widget _kpi(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        children: [
          Icon(Icons.circle, color: color, size: 20),
          const SizedBox(height: 8),
          Text("$value", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // ---------------- HALQAS ----------------
  Widget _halqasSection(TeacherProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("حلقاتك", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        ...provider.myHalqas.map((HalqaModel h) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: _box(),
            child: ListTile(
              leading: Icon(Icons.group, color: Colors.blue.shade700),
              title: Text(h.name),
              subtitle: Text("عدد الطلاب: ${h.studentsCount}"),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/teacher-halqa-students",
                  arguments: h,
                );
              },
            ),
          );
        }),
      ],
    );
  }

  // ---------------- QUICK ACTIONS ----------------
  Widget _quickActions(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      children: [
        // _action("تسجيل تسميع", Icons.menu_book, "/teacher-add-memorization"),
        _action("تسجيل حضور", Icons.calendar_today, "/teacher-attendance"),
        // _action("تسجيل اختبار", Icons.fact_check, "/teacher-add-test"),
        _action("مسح QR", Icons.qr_code_scanner, "/teacher-scan-qr"),
      ],
    );
  }

  Widget _action(String title, IconData icon, String route) {
    return Container(
      decoration: _box(),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: Colors.blue.shade700),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- DRAWER ----------------
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("معلم"),
            accountEmail: Text(""),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("تسجيل الخروج"),
            onTap: () async {
              await context.read<AuthProvider>().logout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
            },
          ),
        ],
      ),
    );
  }

  // ---------------- BOX STYLE ----------------
  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
