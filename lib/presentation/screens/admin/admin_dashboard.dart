import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/admin_providers.dart';

import 'package:quran_center_app/presentation/screens/shared/app_shared_drawer.dart';
// تأكد من مسار الاستيراد

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  
  @override
  void initState() {
    super.initState();
    // جلب الإحصائيات والبيانات فور فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context);

    return Scaffold(
      drawer: const AppSharedDrawer(),
      appBar: AppBar(
        title: const Text("لوحة تحكم الإدارة", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // زر تحديث يدوي سريع
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadDashboardData(),
          ),
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
        child: RefreshIndicator(
          onRefresh: () => provider.loadDashboardData(),
          child: Column(
            children: [
              // شريط تحميل ناعم يظهر بالأعلى بدلاً من إيقاف الشاشة بالكامل
              if (provider.isDashboardLoading)
                const LinearProgressIndicator(color: Colors.indigo),
              
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
      // ============================================================
      // 1) إدارة الموارد البشرية
      // ============================================================
      _buildSectionTitle("إدارة الموارد البشرية"),
      _buildGrid(context, [
        _dashboardCard(
          context,
          title: "الطلاب",
          count: "${provider.students.length} طالب",
          icon: Icons.school,
          color: Colors.blue,
          route: "/admin-students",
        ),
        _dashboardCard(
          context,
          title: "المعلمين",
          count: "${provider.teachers.length} معلم",
          icon: Icons.person,
          color: Colors.teal,
          route: "/admin-teachers",
        ),
        _dashboardCard(
          context,
          title: "الكادر",
          count: "${provider.supervisors.length} موجه",
          icon: Icons.admin_panel_settings,
          color: Colors.blueGrey,
          route: "/admin-staff",
        ),
      ]),

      const SizedBox(height: 30),

      // ============================================================
      // 2) الهيكلة الأكاديمية
      // ============================================================
      _buildSectionTitle("الهيكلة الأكاديمية"),
      _buildGrid(context, [
        _dashboardCard(
          context,
          title: "الحلقات",
          count: "${provider.halqas.length} حلقة",
          icon: Icons.group_work,
          color: Colors.green,
          route: "/admin-halqas",
        ),
        _dashboardCard(
          context,
          title: "السنوات والفصول",
          count: "${provider.semesters.length} فصل",
          icon: Icons.calendar_month,
          color: Colors.orange,
          route: "/admin-academic",
        ),
      ]),

      const SizedBox(height: 30),

      // ============================================================
      // 3) الرقابة والمتابعة
      // ============================================================
      _buildSectionTitle("الرقابة والمتابعة الميدانية"),
      _buildGrid(context, [
        _dashboardCard(
          context,
          title: "الحضور والغياب",
          icon: Icons.co_present,
          color: Colors.indigo,
          route: "/admin-attendance",
        ),
        _dashboardCard(
          context,
          title: "جلسات التسميع",
          icon: Icons.menu_book,
          color: Colors.brown,
          route: "/admin-memorization",
        ),
        _dashboardCard(
          context,
          title: "الاختبارات القرآنية",
          icon: Icons.quiz,
          color: Colors.purple,
          route: "/admin-tests",
        ),
        _dashboardCard(
          context,
          title: "تقدم الطلاب",
          icon: Icons.trending_up,
          color: Colors.deepOrange,
          route: "/admin-progress",
        ),
      ]),

      const SizedBox(height: 30),

      // ============================================================
      // 4) إدارة المحتوى القرآني (جديد)
      // ============================================================
      _buildSectionTitle("إدارة المحتوى القرآني"),
      _buildGrid(context, [
        _dashboardCard(
          context,
          title: "السور",
          icon: Icons.menu_book_outlined,
          color: Colors.green.shade700,
          route: "/admin-surahs",
        ),
        _dashboardCard(
          context,
          title: "الأجزاء",
          icon: Icons.filter_9_plus,
          color: Colors.blue.shade700,
          route: "/admin-parts",
        ),
        _dashboardCard(
          context,
          title: "المناهج",
          icon: Icons.auto_stories,
          color: Colors.deepPurple,
          route: "/admin-curriculum",
        ),
      ]),

      const SizedBox(height: 30),

      // ============================================================
      // 5) التقارير والتحليلات (جديد)
      // ============================================================
      _buildSectionTitle("التقارير والتحليلات"),
      _buildGrid(context, [
        _dashboardCard(
          context,
          title: "تقارير الحضور",
          icon: Icons.fact_check,
          color: Colors.blueGrey,
          route: "/admin-attendance-reports",
        ),
        _dashboardCard(
          context,
          title: "تقارير الاختبارات",
          icon: Icons.assignment_turned_in,
          color: Colors.teal,
          route: "/admin-tests-reports",
        ),
        _dashboardCard(
          context,
          title: "تقارير الحلقات",
          icon: Icons.groups_2,
          color: Colors.green,
          route: "/admin-halqas-reports",
        ),
        _dashboardCard(
          context,
          title: "تقارير الأداء العام",
          icon: Icons.analytics,
          color: Colors.deepOrange,
          route: "/admin-performance",
        ),
      ]),

      const SizedBox(height: 30),

      // ============================================================
      // 6) التواصل والنظام
      // ============================================================
      _buildSectionTitle("التواصل والنظام"),
      _buildGrid(context, [
        _dashboardCard(
          context,
          title: "الإشعارات",
          count: "${provider.notifications.length} إشعار",
          icon: Icons.notifications_active,
          color: Colors.redAccent,
          route: "/admin-notifications",
        ),
        _dashboardCard(
          context,
          title: "إعدادات المركز",
          icon: Icons.settings,
          color: Colors.grey.shade700,
          route: "/admin-settings",
        ),
      ]),

      const SizedBox(height: 40),// مسافة سفلية
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // Widgets مساعدة (Helpers) للحفاظ على نظافة الكود
  // =========================================================================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<Widget> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250, // يضمن التجاوب الممتاز مع الشاشات العريضة والهواتف
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1, // نسبة العرض للطول للبطاقة
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }


  Widget _dashboardCard(
    BuildContext context, {
    required String title,
    String? count, // رقم إحصائي اختياري (مثل: 50 طالب)
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            if (count != null) ...[
              const SizedBox(height: 4),
              Text(
                count,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}