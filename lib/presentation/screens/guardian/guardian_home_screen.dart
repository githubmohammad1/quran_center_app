import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:quran_center_app/presentation/providers/auth_provider.dart';
import 'package:quran_center_app/presentation/providers/guardian_providers.dart';
import 'package:quran_center_app/presentation/screens/shared/app_shared_drawer.dart';

class GuardianHomeScreen extends StatefulWidget {
  const GuardianHomeScreen({super.key});

  @override
  State<GuardianHomeScreen> createState() => _GuardianHomeScreenState();
}

class _GuardianHomeScreenState extends State<GuardianHomeScreen> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // شحن البيانات الأولي بنمط آمن غير حاصر للإطار الرسومي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<GuardianProvider>(context, listen: false);
      provider.loadChildren().then((_) {
        if (provider.children.isNotEmpty && provider.selectedChild == null) {
          provider.loadChildData(provider.children.first.id);
        }
      });
      provider.loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GuardianProvider>(context);


    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "بوابة ولي الأمر",
          style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
        elevation: 2,
      ),
      drawer: const AppSharedDrawer(),
      body: _currentTabIndex == 0 
          ? _buildDashboardTab(provider) 
          : _buildNotificationsTab(provider),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        selectedItemColor: Colors.teal[700],
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontFamily: "Cairo"),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "لوحة المتابعة"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: "مركز الإشعارات"),
        ],
      ),
    );
  }

  // =========================================================================
  // 1. بناء تبويب لوحة المتابعة (Dashboard) المحصن
  // =========================================================================
  Widget _buildDashboardTab(GuardianProvider provider) {
    if (provider.loading && provider.children.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.selectedChild == null) {
      return _buildErrorWidget(provider.error!, () {
        provider.loadChildren().then((_) {
          if (provider.children.isNotEmpty) {
            provider.loadChildData(provider.children.first.id);
          }
        });
      });
    }

    if (provider.children.isEmpty) {
      return _buildEmptyState("لا يوجد أبناء مسجلون مرتبطون برقم الهاتف هذا حالياً.");
    }

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
          // قائمة اختيار الابن النشط
          _buildChildSelector(provider),
          const SizedBox(height: 16),

          if (provider.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.error != null)
            _buildErrorWidget(provider.error!, () {
              if (provider.selectedChild != null) {
                provider.loadChildData(provider.selectedChild!.id);
              }
            })
          else ...[
            // عرض محتويات اللوحة بأمان بعد تجاوز أخطاء الحافة
            _buildProgressSection(provider),
            const SizedBox(height: 16),
            _buildAttendanceSection(provider),
            const SizedBox(height: 16),
            _buildMemorizationSection(provider),
          ]
        ],
      ),
    );
  }

  // =========================================================================
  // 2. بناء تبويب مركز الإشعارات مع ميزة التحديث التفاؤلي
  // =========================================================================
  Widget _buildNotificationsTab(GuardianProvider provider) {
    if (provider.loading && provider.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.notifications.isEmpty) {
      return _buildEmptyState("مركز الإشعارات فارغ حالياً.");
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadNotifications(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: provider.notifications.length,
        itemBuilder: (context, index) {
          final item = provider.notifications[index];
          return Card(
            elevation: item.isRead ? 0.5 : 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            color: item.isRead ? Colors.white : Colors.teal[50]?.withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: _getNotificationIcon(item.category),
              title: Text(
                item.title,
                style: TextStyle(
                  fontFamily: "Cairo",
                  fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                  color: item.isRead ? Colors.black87 : Colors.teal[900],
                ),
              ),
              subtitle: Text(
                item.message,
                style: const TextStyle(fontFamily: "Cairo", fontSize: 13, color: Colors.black54),
              ),
              trailing: !item.isRead
                  ? IconButton(
                      icon: const Icon(Icons.done_all_rounded, color: Colors.teal),
                      tooltip: "تحديد كمقروء",
                      onPressed: () => provider.markNotificationAsRead(item.id),
                    )
                  : const Icon(Icons.check_circle_outline_rounded, color: Colors.grey, size: 18),
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // 3. المساعدات الرسومية ومكونات الواجهة الفرعية (UI Sub-Components)
  // =========================================================================
  Widget _buildChildSelector(GuardianProvider provider) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: provider.selectedChild?.id,
            isExpanded: true,
            hint: const Text("اختر الابن للمتابعة", style: TextStyle(fontFamily: "Cairo")),
            icon: const Icon(Icons.arrow_drop_down_circle_rounded, color: Colors.teal),
            items: provider.children.map((child) {
              return DropdownMenuItem<int>(
                value: child.id,
                child: Text(
                  child.fullName,
                  style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
            onChanged: (childId) {
              if (childId != null) {
                provider.loadChildData(childId);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(GuardianProvider provider) {
    final prog = provider.progress;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [Colors.teal[700]!, Colors.teal[500]!]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
                SizedBox(width: 8),
                Text("خلاصة التقدم الدراسي والقمم", style: TextStyle(color: Colors.white, fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProgressStatItem("النقاط التراكمية", "${prog?.points ?? 0} ن"),
                _buildProgressStatItem("الصفحات المحفوظة", "${prog?.totalPagesMemorized ?? 0} ص"),
                _buildProgressStatItem("الاختبارات المجتازة", "${(prog?.totalPartsTested ?? 0) + (prog?.totalSurahsTested ?? 0)}"),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStatItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontFamily: "Cairo", fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildAttendanceSection(GuardianProvider provider) {
    // حساب إحصائي سريع لعرض ملخص أرباع الحضور
    final total = provider.attendance.length;
    final present = provider.attendance.where((a) => a.status.toLowerCase() == 'present').length;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("سجل الانضباط والحضور", style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 15)),
                Text("نسبة الالتزام: $present/$total", style: TextStyle(fontFamily: "Cairo", fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const Divider(),
            if (provider.attendance.isEmpty)
              const Text("لا توجد سجلات حضور مسجلة لهذا الفصل حتى الآن.", style: TextStyle(fontFamily: "Cairo", fontSize: 13, color: Colors.black38))
            else
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.attendance.length,
                  itemBuilder: (context, index) {
                    final item = provider.attendance[index];
                    final isPresent = item.status.toLowerCase() == 'present';
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isPresent ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isPresent ? Colors.green : Colors.red),
                      ),
                      child: Center(
                        child: Text(
                          "${item.date}: ${isPresent ? 'حضور' : 'غياب'}",
                          style: TextStyle(fontFamily: "Cairo", fontSize: 11, color: isPresent ? Colors.green[900] : Colors.red[900], fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemorizationSection(GuardianProvider provider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("جلسات التسميع اليومية الأخيرة", style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(),
            if (provider.memorizationSessions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("لا توجد جلسات حفظ مضافة في الأيام القليلة الماضية.", style: TextStyle(fontFamily: "Cairo", fontSize: 13, color: Colors.black38)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.memorizationSessions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final session = provider.memorizationSessions[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal[50],
                      child: Icon(Icons.menu_book_rounded, color: Colors.teal[700], size: 20),
                    ),
                    title: Text(
                      "من صفحة ${session.pageFrom} إلى صفحة ${session.pageTo}",
                      style: const TextStyle(fontFamily: "Cairo", fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text("التاريخ: ${session.date}", style: const TextStyle(fontSize: 12)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        _translateGrade(session.grade),
                        style: TextStyle(fontFamily: "Cairo", fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber[900]),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildErrorWidget(String error, VoidOnPressed onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(fontFamily: "Cairo", color: Colors.red, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("إعادة المحاولة", style: TextStyle(fontFamily: "Cairo")),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_done_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontFamily: "Cairo", color: Colors.grey[600], fontSize: 14)),
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
      default: return grade;
    }
  }
}

typedef VoidOnPressed = void Function();