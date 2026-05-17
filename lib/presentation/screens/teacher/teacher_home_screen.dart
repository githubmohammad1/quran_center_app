import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/auth_provider.dart';
import '../../providers/teacher_provider.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int? _selectedHalqaId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final teacher = context.read<TeacherProvider>();
      await teacher.loadDashboardData();
      if (teacher.myHalqas.isNotEmpty) {
        _selectedHalqaId = teacher.myHalqas.first.id;
        await teacher.loadHalqaStudents(_selectedHalqaId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final teacher = context.watch<TeacherProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("لوحة المعلم"), elevation: 0),
      drawer: _buildDrawer(auth),
      body: teacher.loading && teacher.myHalqas.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await teacher.loadDashboardData();
                if (_selectedHalqaId != null) {
                  await teacher.loadHalqaStudents(_selectedHalqaId!);
                }
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _header(auth),
                  const SizedBox(height: 20),
                  _stats(teacher),
                  const SizedBox(height: 20),
                  _halqasSection(teacher),
                  const SizedBox(height: 20),
                  _studentsSection(teacher),
                  const SizedBox(height: 20),
                  _quickActions(context),
                ],
              ),
            ),
    );
  }

  // -----------------------------
  // 1) الهيدر
  // -----------------------------
  Widget _header(AuthProvider auth) {
    final name = auth.user?.fullName ?? "أستاذنا الكريم";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.indigo],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.indigo),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "مرحبًا،",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "نسأل الله أن يبارك في تعليمك للقرآن 🌿",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // 2) الإحصائيات من dashboardStats
  // -----------------------------
  Widget _stats(TeacherProvider teacher) {
    final s = teacher.dashboardStats;

    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: "الصفحات المحفوظة",
            value: "${s["total_pages_memorized"] ?? 0}",
            icon: Icons.menu_book,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            title: "الأجزاء المختبَرة",
            value: "${s["total_parts_tested"] ?? 0}",
            icon: Icons.fact_check,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            title: "النقاط",
            value: "${s["total_points"] ?? 0}",
            icon: Icons.star,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // 3) الحلقات
  // -----------------------------
  Widget _halqasSection(TeacherProvider teacher) {
    final halqas = teacher.myHalqas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "حلقاتي",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (halqas.isEmpty)
          const Text("لا توجد حلقات مسندة لك حالياً.")
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: halqas.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final h = halqas[index];
                final isSelected = h.id == _selectedHalqaId;

                return GestureDetector(
                  onTap: () async {
                    setState(() => _selectedHalqaId = h.id);
                    await teacher.loadHalqaStudents(h.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 220,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.indigo.shade100
                          : Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? Colors.indigo : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "الفصل: ${h.semester?.name ?? '-'}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          "عدد الطلاب: ${h.students.length}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // -----------------------------
  // 4) طلاب الحلقة الحالية
  // -----------------------------
  Widget _studentsSection(TeacherProvider teacher) {
    final students = teacher.currentHalqaStudents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "طلاب الحلقة الحالية",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (_selectedHalqaId == null)
          const Text("اختر حلقة من الأعلى لعرض طلابها.")
        else if (teacher.loading && students.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (students.isEmpty)
          const Text("لا يوجد طلاب مسجلون في هذه الحلقة.")
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final s = students[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(s.fullName),
                subtitle: Text(s.parentPhone ?? ""),
              );
            },
          ),
      ],
    );
  }

  // -----------------------------
  // 5) الروابط السريعة
  // -----------------------------
  Widget _quickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "روابط سريعة",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          children: [
            _actionCard(
              context,
              "تسجيل حضور",
              Icons.playlist_add_check,
              "/teacher-attendance",
            ),
            _actionCard(
              context,
              "تسجيل تسميع",
              Icons.menu_book_outlined,
              "/teacher-memorization",
            ),
            _actionCard(
              context,
              "تسجيل اختبار",
              Icons.fact_check_outlined,
              "/teacher-tests",
            ),
            _actionCard(context, "طلابي", Icons.group, "/teacher-students"),
            _actionCard(
              context,
              "إشعارات",
              Icons.notifications,
              "/teacher-notifications",
            ),
            _actionCard(
              context,
              "إعدادات",
              Icons.settings,
              "/teacher-settings",
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: Colors.indigo),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------
  // 6) Drawer
  // -----------------------------
  Drawer _buildDrawer(AuthProvider auth) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(auth.user?.fullName ?? ""),
            accountEmail: Text(auth.user?.parentPhone ?? ""),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("الملف الشخصي"),
            onTap: () => Navigator.pushNamed(context, "/profile"),
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
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/login",
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
