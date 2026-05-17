import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/auth_provider.dart';
import '../../providers/student_providers.dart';


class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();

    return Scaffold(
      drawer: _buildDrawer(provider),
      appBar: AppBar(
        title: const Text("لوحة التحكم"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FA), Color(0xFFF1F3F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : provider.profile == null
                ? const Center(child: Text("لا توجد بيانات"))
                : RefreshIndicator(
                    onRefresh: () async => provider.loadAll(),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _header(provider),
                        const SizedBox(height: 20),
                        _kpiCards(provider),
                        const SizedBox(height: 20),
                        _progressChart(provider),
                        const SizedBox(height: 20),
                        _attendanceSummary(provider),
                        const SizedBox(height: 20),
                        _recentNotifications(provider),
                        const SizedBox(height: 20),
                        _recentMemorization(provider),
                        const SizedBox(height: 20),
                        _recentTests(provider),
                        const SizedBox(height: 20),
                        _quickActions(context),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 1) الهيدر
  // ---------------------------------------------------------
  Widget _header(StudentProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.green.shade100,
            child: Icon(Icons.person, size: 40, color: Colors.green.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "مرحبًا، ${provider.profile!.fullName}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 2) بطاقات KPI
  // ---------------------------------------------------------
  Widget _kpiCards(StudentProvider provider) {
    final p = provider.progress;

    if (p == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(child: _kpi("الصفحات", p.totalPagesMemorized, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _kpi("الأجزاء", p.totalPartsTested, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _kpi("النقاط", p.points, Colors.green)),
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
          Text(
            "$value",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 3) مخطط التقدم
  // ---------------------------------------------------------
  Widget _progressChart(StudentProvider provider) {
    final p = provider.progress!;
    final maxValue = [
      p.totalPagesMemorized.toDouble(),
      p.totalPartsTested.toDouble(),
      p.points.toDouble(),
    ].reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("مخطط التقدم", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bar("الصفحات", p.totalPagesMemorized, maxValue, Colors.blue),
              _bar("الأجزاء", p.totalPartsTested, maxValue, Colors.orange),
              _bar("النقاط", p.points, maxValue, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar(String label, int value, double max, Color color) {
    final height = (value / max) * 120;

    return Expanded(
      child: Column(
        children: [
          Container(
            height: height,
            width: 22,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
          Text("$value", style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 4) ملخص الحضور
  // ---------------------------------------------------------
  Widget _attendanceSummary(StudentProvider provider) {
    final total = provider.attendance.length;
    final present = provider.attendance.where((a) => a.status == "present").length;
    final absent = provider.attendance.where((a) => a.status == "absent").length;
    final late = provider.attendance.where((a) => a.status == "late").length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("الحضور", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              _att("إجمالي", total, Colors.blue),
              _att("حضور", present, Colors.green),
              _att("غياب", absent, Colors.red),
              _att("تأخر", late, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _att(String title, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(Icons.circle, color: color, size: 18),
          const SizedBox(height: 6),
          Text("$value", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 5) آخر الإشعارات
  // ---------------------------------------------------------
  Widget _recentNotifications(StudentProvider provider) {
    final list = provider.notifications.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("آخر الإشعارات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...list.map((n) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: _box(),
            child: ListTile(
              leading: Icon(Icons.notifications, color: Colors.green.shade700),
              title: Text(n.title),
              subtitle: Text(n.message),
            ),
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------
  // 6) آخر التسميع
  // ---------------------------------------------------------
  Widget _recentMemorization(StudentProvider provider) {
    final list = provider.memorization.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("آخر التسميع", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...list.map((m) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: _box(),
            child: ListTile(
              leading: Icon(Icons.menu_book, color: Colors.green.shade700),
              title: Text("من ${m.pageFrom} إلى ${m.pageTo}"),
              subtitle: Text("التقدير: ${m.grade}"),
            ),
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------
  // 7) آخر الاختبارات
  // ---------------------------------------------------------
  Widget _recentTests(StudentProvider provider) {
    final list = provider.tests.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("آخر الاختبارات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...list.map((t) {
          final isPart = t.testType == "PART";
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: _box(),
            child: ListTile(
              leading: Icon(
                isPart ? Icons.fact_check : Icons.menu_book,
                color: isPart ? Colors.orange : Colors.blue,
              ),
              title: Text(
                isPart
                    ? "اختبار جزء رقم ${t.partNumber}"
                    : "اختبار سورة ${t.surah?.name ?? ''}",
              ),
              subtitle: Text("التقدير: ${t.grade}"),
            ),
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------
  // 8) الروابط السريعة
  // ---------------------------------------------------------
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
        _action("الحضور", Icons.calendar_today, "/student-attendance"),
        _action("الاختبارات", Icons.fact_check, "/student-tests"),
        _action("الإشعارات", Icons.notifications, "/student-notifications"),
        _action("التقدم", Icons.bar_chart, "/student-progress"),
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
              Icon(icon, size: 36, color: Colors.green.shade700),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 9) Drawer
  // ---------------------------------------------------------
  Drawer _buildDrawer(StudentProvider provider) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(provider.profile?.fullName ?? ""),
            accountEmail: Text(provider.profile?.parentPhone ?? ""),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
            decoration: BoxDecoration(color: Colors.green.shade700),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("تغيير كلمة المرور"),
            onTap: () => Navigator.pushNamed(context, "/change-password"),
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

  // ---------------------------------------------------------
  // صندوق تصميم موحد
  // ---------------------------------------------------------
  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
