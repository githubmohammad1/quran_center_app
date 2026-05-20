
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/data/models/person_model.dart';
import 'package:quran_center_app/presentation/providers/student_providers.dart';


class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();
    // استدعاء الدالة الشاملة loadAll() فور تحميل الشاشة [1]
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    // مراقبة الـ StudentProvider للتفاعل مع البيانات المحدثة
    final studentProvider = context.watch<StudentProvider>();
    final progress = studentProvider.progress;
    final profile = studentProvider.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة تحكم الطالب", style: TextStyle(fontFamily: "Cairo")),
        centerTitle: true,
        elevation: 0,
        actions: [
          // أيقونة الإشعارات مع عرض عدد غير المقروء إن وُجد
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () => Navigator.pushNamed(context, "/student-notifications"),
          ),
        ],
      ),
      body: studentProvider.loading
          ? const Center(child: CircularProgressIndicator()) // حالة التحميل [2]
          : RefreshIndicator(
              onRefresh: () => studentProvider.loadAll(), // دعم سحب الشاشة للتحديث
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. قسم الترحيب والملف الشخصي [3]
                    _buildHeader(profile?.fullName ?? "طالبنا العزيز"),
                    const SizedBox(height: 25),

                    // 2. بطاقات الإحصائيات (مؤمنة ضد القيم الفارغة باستخدام ??) [13، 14]
                    Text("تقدمك الحالي", style: _headerStyle()),
                    const SizedBox(height: 12),
                    _buildStatsGrid(progress),
                    const SizedBox(height: 30),

                    // 3. قسم الوصول السريع (Quick Actions) [4]
                    Text("الخدمات الطلابية", style: _headerStyle()),
                    const SizedBox(height: 12),
                    _buildActionGrid(context, profile),
                  ],
                ),
              ),
            ),
    );
  }

  TextStyle _headerStyle() => const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Cairo");

  Widget _buildHeader(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo, Colors.indigo.shade400]),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 35, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("مرحباً بك،", style: TextStyle(color: Colors.white70, fontFamily: "Cairo")),
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(var progress) {
    // عرض الإحصائيات القادمة من StudentProgressModel في الجانغو [9، 13]
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _statCard("الصفحات المحفوظة", "${progress?.totalPagesMemorized ?? 0}", Icons.menu_book, Colors.blue),
        _statCard("مجموع النقاط", "${progress?.points ?? 0}", Icons.stars, Colors.orange),
        _statCard("الأجزاء المختبرة", "${progress?.totalPartsTested ?? 0}", Icons.fact_check, Colors.green),
        _statCard("السور المختبرة", "${progress?.totalSurahsTested ?? 0}", Icons.auto_stories, Colors.purple),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: "Cairo")),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color, fontFamily: "Cairo")),
        ],
      ),
    );
  }

Widget _buildActionGrid(BuildContext context, PersonModel? profile) {
  return GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 3,
    children: [
      _actionItem(context, "الحضور", Icons.calendar_month, "/student-attendance"),
      _actionItem(context, "الاختبارات", Icons.quiz, "/student-tests"),
      _actionItem(context, "التقدم", Icons.trending_up, "/student-progress"),

      // هنا الآن profile معروف
      _actionItem(
        context,
        "البطاقة الرقمية",
        Icons.qr_code,
        "/shared-student-qr",
        extra: profile,
      ),
    ],
  );
}


 Widget _actionItem(
  BuildContext context,
  String title,
  IconData icon,
  String route, {
  Object? extra,
}) {
  return InkWell(
    onTap: () => Navigator.pushNamed(context, route, arguments: extra),
    child: Column(
      children: [
        CircleAvatar(

          radius: 25,
          backgroundColor: Colors.indigo.withOpacity(0.1),
          child: Icon(icon, color: Colors.indigo),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 13, fontFamily: "Cairo")),
      ],
    ),
  );
}

}