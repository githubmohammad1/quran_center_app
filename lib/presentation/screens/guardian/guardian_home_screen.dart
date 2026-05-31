import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:quran_center_app/data/models/attendance_model.dart';
import 'package:quran_center_app/data/models/memorization_session_model.dart';
import 'package:quran_center_app/data/models/quran_test_model.dart';
import 'package:quran_center_app/presentation/providers/auth_provider.dart';
import 'package:quran_center_app/presentation/providers/guardian_providers.dart'; // لتنسيق التواريخ بشكل هادئ ومنظم


class GuardianHomeScreen extends StatefulWidget {
  const GuardianHomeScreen({super.key});

  @override
  State<GuardianHomeScreen> createState() => _GuardianHomeScreenState();
}

class _GuardianHomeScreenState extends State<GuardianHomeScreen> {
  int _currentTabIndex = 0; // التحكم بالتبويب النشط (لوحة التحكم / الإشعارات)

  @override
  void initState() {
    super.initState();
    // شحن بيانات الأبناء والإشعارات فور تهيئة الواجهة لضمان الجاهزية التزامنية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<GuardianProvider>(context, listen: false);
      provider.loadChildren();
      provider.loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GuardianProvider>(context);
final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[50] ?? const Color(0xFFFAFAFA),
      drawer: _buildDrawer(
        context, 
        authProvider, 
        authProvider.user?.fullName ?? "اسم المستخدم", 
        authProvider.user?.parentPhone ?? "لا يوجد رقم هاتف"
      ),
      appBar: AppBar(
        title: Text(
          _currentTabIndex == 0 ? "لوحة المتابعة اليومية" : "مركز الإشعارات والتنبيهات",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_currentTabIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                if (provider.selectedChild != null) {
                  provider.loadChildData(provider.selectedChild!.id);
                }
              },
            )
        ],
      ),
      body: provider.loading && provider.children.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? _buildErrorPlaceholder(provider.error!, () => provider.loadChildren())
              : provider.children.isEmpty
                  ? const Center(child: Text("لا يوجد أبناء مسجلون برقم الهاتف هذا"))
                  : IndexedStack(
                      index: _currentTabIndex,
                      children: [
                        _buildDashboardTab(provider),
                        _buildNotificationsTab(provider),
                      ],
                    ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[400],
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: "لوحة التحكم",
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_active_rounded),
                // إظهار شارة حمراء ذكية إذا كان هناك إشعارات غير مقروءة
                if (provider.notifications.any((n) => !n.isRead))
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                    ),
                  )
              ],
            ),
            label: "الإشعارات",
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 1. التبويب الأول: لوحة التحكم الموحدة والديناميكية
  // =========================================================================
  Widget _buildDashboardTab(GuardianProvider provider) {
    return RefreshIndicator(
      onRefresh: () async {
        if (provider.selectedChild != null) {
          await provider.loadChildData(provider.selectedChild!.id);
        }
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // أ) شريط اختيار الأبناء الأفقي (Child Selector Matrix)
          const Text(
            "الأبناء المسجلون:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.children.length,
              itemBuilder: (context, index) {
                final child = provider.children[index];
                final isSelected = provider.selectedChild?.id == child.id;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(
                      child.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.white,
                    elevation: isSelected ? 2 : 0,
                    onSelected: (selected) {
                      if (selected) provider.selectChild(child);
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 24),

          // ب) التحقق من وجود بيانات محملة للابن المحدّد للبدء برسم الإحصائيات
          if (provider.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.selectedChild == null)
            const Center(child: Text("الرجاء اختيار ابن لاستعراض بياناته"))
          else ...[
            // 1. بطاقة التقدم التراكمي والنقاط (Progress Assessment Card)
            _buildProgressCard(provider.progress),
            const SizedBox(height: 16),

            // 2. سجل الحفظ والتسميع اليومي (Memorization Track)
            _buildSectionHeader("سجل التسميع اليومي الأخير", Icons.menu_book_rounded),
            _buildMemorizationList(provider.memorizationSessions),
            const SizedBox(height: 16),

            // 3. سجل الاختبارات الرسمية (Quran Tests Ledger)
            _buildSectionHeader("نتائج الاختبارات والأجزاء", Icons.assignment_turned_in_rounded),
            _buildTestsList(provider.tests),
            const SizedBox(height: 16),

            // 4. خلاصة الغياب والحضور (Attendance Analytics Summary)
            _buildSectionHeader("خلاصة تفاعل الحضور والالتزام", Icons.calendar_month_rounded),
            _buildAttendanceSummary(provider.attendance),
          ],
        ],
      ),
    );
  }

  // =========================================================================
  // 2. التبويب الثاني: مركز التحكم بالإشعارات
  // =========================================================================
  Widget _buildNotificationsTab(GuardianProvider provider) {
    if (provider.notifications.isEmpty) {
      return const Center(
        child: Text("مركز الإشعارات فارغ حالياً.", style: TextStyle(color: Colors.grey)),
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.loadNotifications(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.notifications.length,
        itemBuilder: (context, index) {
          final notif = provider.notifications[index];
          return Card(
            elevation: notif.isRead ? 0 : 2,
            color: notif.isRead ? Colors.white.withOpacity(0.8) : Colors.amber[50]?.withOpacity(0.5),
            // ❌ السطر القديم الخاطئ:
// margin: const EdgeInsets.bottom step(8),

//  السطر الجديد المصحح والمستمتل:
margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: notif.isRead ? Colors.transparent : Colors.amber.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: _getNotificationIcon(notif.category),
              title: Text(
                notif.title,
                style: TextStyle(
                  fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(notif.message, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text(
                    notif.createdAt, // يفضل تنسيقها لاحقاً حسب الـ Backend
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
              trailing: !notif.isRead
                  ? IconButton(
                      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
                      tooltip: "تحديد كمقروء",
                      onPressed: () => provider.markNotificationAsRead(notif.id),
                    )
                  : const Icon(Icons.done_all_rounded, size: 18, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // 3. العناصر والمكونات البصرية المصغرة (UI Components Matrix)
  // =========================================================================

  Widget _buildProgressCard(dynamic progress) {
    final int points = progress?.totalPoints ?? 0;
    final int totalPages = progress?.totalPagesMemorized ?? 0;

    return Card(
      elevation: 4,
      shadowColor: Colors.blueAccent.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias, // 🚀 تحصين الجودة: يضمن قص أطراف الحاوية الداخلية لتطابق تدوير البطاقة
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)], // لون نيلي هادئ فخم
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        key: const ValueKey('progress_card'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn("رصيد النقاط التراكمي", "$points ن", Icons.stars_rounded),
            Container(width: 1, height: 50, color: Colors.white24),
            _buildStatColumn("إجمالي الصفحات المحفوظة", "$totalPages ص", Icons.chrome_reader_mode_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 28),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildMemorizationList(List<MemorizationSessionModel> sessions) {
    if (sessions.isEmpty) return _buildEmptyCard("لا توجد جلسات تسميع مسجلة لهذا الفصل.");
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length > 3 ? 3 : sessions.length, // نكتفي بعرض آخر 3 جلسات للتوازن البصري
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.menu_book, color: Colors.green)),
            title: Text("من الصفحة ${session.pageFrom} إلى الصفحة ${session.pageTo}"),
            subtitle: Text("التاريخ: ${session.date}"),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
              child: Text(
                _translateGrade(session.grade),
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }
Widget _buildDrawer(BuildContext context, AuthProvider auth, String name, String phone) { // [cite: 149]
    final userModel = auth.user; // [cite: 149]
    return Drawer( // [cite: 150]
      child: ListView( // [cite: 150]
        padding: EdgeInsets.zero, // [cite: 150]
        children: [ // [cite: 150]
          UserAccountsDrawerHeader( // [cite: 150]
            accountName: Text( // [cite: 150]
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "Cairo"), // [cite: 150]
            ),
            accountEmail: Text(phone), // [cite: 151]
            decoration: BoxDecoration(color: Theme.of(context).primaryColor), // [cite: 151]
            currentAccountPicture: const CircleAvatar( // [cite: 151]
              backgroundColor: Colors.white, // [cite: 151]
              child: Icon(Icons.person, size: 40, color: Color(0xFF1E3C72)), // [cite: 151]
            ),
          ),
          ListTile( // [cite: 152]
            leading: const Icon(Icons.dashboard_rounded, color: Color(0xFF2A5298)), // [cite: 152]
            title: const Text("لوحة المتابعة لولي الأمر", style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.w500)), // [cite: 152]
            onTap: () => Navigator.pop(context), // [cite: 152]
          ),

          // 🚀 الحقل الذكي: التحقق من الصلاحيات الإضافية للحساب للتبديل بين الواجهات
          if (userModel != null && userModel.roles.contains('teacher')) ...[ // [cite: 152, 153]
            const Divider(), // [cite: 153]
            Padding( // [cite: 153]
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // [cite: 153]
              child: Text( // [cite: 153]
                "صلاحيات المعلم المساعد", // [cite: 153]
                style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold, fontFamily: "Cairo"), // [cite: 154]
              ),
            ),
            ListTile( // [cite: 154]
              leading: const Icon(Icons.gavel_rounded, color: Colors.orange), // [cite: 154]
              title: const Text("الانتقال إلى لوحة الأستاذ", style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.w500)), // [cite: 154]
              subtitle: const Text("لإدارة حلقة الصغار وتسميعهم", style: TextStyle(fontSize: 11)), // [cite: 155]
              onTap: () { // [cite: 155]
                Navigator.pop(context); // [cite: 155]
                auth.switchRole('teacher'); // [cite: 156]
                Navigator.pushReplacementNamed(context, "/teacher-home"); // [cite: 157]
              },
            ),
          ],

          const Divider(), // [cite: 158]
          ListTile( // [cite: 158]
            leading: const Icon(Icons.logout_rounded, color: Colors.red), // [cite: 158]
            title: const Text("تسجيل الخروج", style: TextStyle(color: Colors.red, fontFamily: "Cairo", fontWeight: FontWeight.bold)), // [cite: 158]
            onTap: () async { // [cite: 158]
              await auth.logout(); // [cite: 159]
              if (!mounted) return; // [cite: 159]
              Navigator.pop(context); // [cite: 159]
              Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false); // [cite: 159]
            },
          ),
        ],
      ),
    );
  }
  Widget _buildTestsList(List<QuranTestModel> tests) {
    if (tests.isEmpty) return _buildEmptyCard("لم يقم الابن بإجراء اختبارات رسمية بعد.");
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tests.length > 3 ? 3 : tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        final title = test.testType == 'parts' ? "اختبار جزء: ${test.partNumber}" : "اختبار سورة: ${test.surah}";
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFE3F2FD), child: Icon(Icons.workspace_premium_rounded, color: Colors.blue)),
            title: Text(title),
            subtitle: Text("التاريخ: ${test.date}"),
            trailing: Text(
              "${test.grade}/100",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceSummary(List<AttendanceModel> attendanceList) {
    if (attendanceList.isEmpty) return _buildEmptyCard("لا توجد بيانات حضور مسجلة.");
    
    // حساب كمي دقيق ومباشر للإحصائيات الحيوية
    final present = attendanceList.where((a) => a.status == "حضور").length;
    final absent = attendanceList.where((a) => a.status == "غياب").length;
    final delayed = attendanceList.where((a) => a.status == "تأخر").length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAttendanceChip("حضور: $present", Colors.green),
        _buildAttendanceChip("غياب: $absent", Colors.red),
        _buildAttendanceChip("تأخر: $delayed", Colors.orange),
      ],
    );
  }

  Widget _buildAttendanceChip(String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color.withOpacity(0.1),
         borderRadius: BorderRadius.circular(10),
         border: Border.all(width: 1, color: color.withOpacity(0.2))
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2A5298), size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Card(
      color: Colors.grey[100],
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(message, style: const TextStyle(color: Colors.grey, fontSize: 13))),
      ),
    );
  }

  Widget _buildErrorPlaceholder(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text("إعادة المحاولة")),
          ],
        ),
      ),
    );
  }

  Icon _getNotificationIcon(String category) {
    switch (category) {
      case "MEMORIZATION": return const Icon(Icons.menu_book_rounded, color: Colors.green);
      case "TEST": return const Icon(Icons.assignment_turned_in_rounded, color: Colors.blue);
      case "ATTENDANCE": return const Icon(Icons.no_accounts_rounded, color: Colors.red);
      case "SUCCESS": return const Icon(Icons.emoji_events_rounded, color: Colors.amber);
      default: return const Icon(Icons.notifications_rounded, color: Colors.grey);
    }
  }

  String _translateGrade(String grade) {
    switch (grade.toLowerCase()) {
      case "excellent": return "ممتاز";
      case "very_good": return "جيد جداً";
      case "good": return "جيد";
      case "acceptable": return "مقبول";
      case "weak": return "ضعيف";
      default: return grade;
    }
  }
}