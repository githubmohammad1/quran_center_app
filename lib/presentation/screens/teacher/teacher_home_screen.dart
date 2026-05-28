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
    // جلب البيانات عند بناء الشاشة لأول مرة بصيغة PostFrameCallback لمنع تداخل الحالات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔍 جلب الحالات (State Management)
    final provider = context.watch<TeacherProvider>();
    final authProvider = context.watch<AuthProvider>();
final userName = authProvider.user?.fullName ?? "أستاذنا الكريم";
    final userPhone = authProvider.user?.parentPhone ?? "رقم غير متوفر";
 


    return Scaffold(
      drawer: _buildDrawer(context, authProvider, userName, userPhone),
      appBar: AppBar(
        title: const Text("لوحة التحكم والتعليم"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // تحسين أداء: استدعاء الدالة عبر سياق القراءة عند التنفيذ المباشر لمنع الـ Over-triggering
            onPressed: () => context.read<TeacherProvider>().loadDashboardData(isRefresh: true),
          ),
        ],
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
        // 🛠️ تصحيح المطابقة: التبديل الشرطي السليم بناءً على حالة تحميل الـ Dashboard
        child: provider.isDashboardLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => context.read<TeacherProvider>().loadDashboardData(isRefresh: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    // هندسة الحماية: عرض رسالة خطأ صريحة في حال وجود مشكلة بالشبكة أو الباك إند
                    if (provider.error != null) _buildErrorCard(provider),

                    _header(userName),
                    const SizedBox(height: 20),
                    _kpiCards(provider),
                    const SizedBox(height: 20),
                    _halqasSection(provider),
                    const SizedBox(height: 20),
                    _quickActions(context),
                  ],
                ),
              ),
      ),
    );
  }

  // ---------------- ERROR CARD ----------------
  Widget _buildErrorCard(TeacherProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.error!,
              style: TextStyle(color: Colors.red.shade900, fontSize: 14),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red.shade700, size: 18),
            onPressed: () => provider.clearError(),
          ),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header(String name) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "أهلاً بك،",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- KPIs ----------------
  Widget _kpiCards(TeacherProvider provider) {
    final stats = provider.dashboardStats;
    print(stats);
    return Row(
      children: [
        Expanded(
          child: _kpi(
            "الصفحات",
            stats["total_pages_memorized"] ?? 0,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _kpi(
            "الأجزاء",
            stats["total_parts_tested"] ?? 0,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _kpi("الطلاب", stats["students_count"] ?? 0, Colors.blue),
        ),
      ],
    );
  }

  Widget _kpi(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        children: [
          Icon(Icons.insights, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            "$value",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ---------------- HALQAS ----------------
  Widget _halqasSection(TeacherProvider provider) {
    if (provider.myHalqas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _box(),
        child: const Center(
          child: Text(
            "لا توجد حلقات مسندة إليك حالياً.",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "حلقاتك التعليمية",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...provider.myHalqas.map((HalqaModel h) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: _box(),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: Icon(Icons.class_, color: Colors.blue.shade700),
                title: Text(
                  h.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text("عدد الطلاب المقيدين: ${h.studentsCount }"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    "/teacher-halqa-students",
                    arguments: h,
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  // ---------------- QUICK ACTIONS ----------------
  Widget _quickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "إجراءات سريعة",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          children: [
            _action(
              "تسجيل حضور اليوم",
              Icons.calendar_today,
              "/teacher-attendance",
            ),
            _action("مسح رمز QR", Icons.qr_code_scanner, "/teacher-scan-qr"),
          ],
        ),
      ],
    );
  }

  Widget _action(String title, IconData icon, String route) {
    return Container(
      decoration: _box(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(context, route),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 32, color: Colors.blue.shade700),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- DRAWER ----------------
 Widget _buildDrawer(BuildContext context, AuthProvider auth, String name, String phone) {
    final userModel = auth.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "Cairo"),
            ),
            accountEmail: Text(phone),
            decoration: const BoxDecoration(color: Colors.blue),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.blue),
            title: const Text("لوحة التحكم العامة للمعلم", style: TextStyle(fontFamily: "Cairo")),
            onTap: () => Navigator.pop(context),
          ),

          // 🚀 الحقن المنطقي: إذا كان الأستاذ يملك أيضاً دور طالب (طالبك الكبير)، نظهر زر العودة لحلقته
          if (userModel != null && userModel.roles.contains('student')) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "بياناتي الشخصية",
                style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold, fontFamily: "Cairo"),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.school, color: Colors.green),
              title: const Text("التبديل إلى لوحة الطالب", style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.w500)),
              subtitle: const Text("لمتابعة حفظك وتسميعك عند الشيخ", style: TextStyle(fontSize: 11)),
              onTap: () {
                // 1. إغلاق الـ Drawer لمنع حدوث غلق غير متناسق للواجهات
                Navigator.pop(context);
                
                // 2. تحديث الدور النشط محلياً في الـ State
                auth.switchRole('student');
                
                // 3. الاستبدال الآمن للشاشة الحالية لشاشة الطالب وتصفير الـ Stack
                Navigator.pushReplacementNamed(context, "/student-home");
              },
            ),
          ],

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("تسجيل الخروج", style: TextStyle(color: Colors.red, fontFamily: "Cairo")),
            onTap: () async {
              await auth.logout();
              if (!mounted) return;
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
            },
          ),
        ],
      ),
    );
  }


  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}