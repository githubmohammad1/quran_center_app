import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    // شحن قائمة الأبناء عند الإقلاع بشكل آمن غير حاصر للإطار الرسومي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuardianProvider>().loadChildren();
      context.read<GuardianProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GuardianProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _currentTabIndex == 0 ? "أبنائي" : "مركز الإشعارات",
          style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
        elevation: 2,
      ),
      drawer: const AppSharedDrawer(),
      body: _currentTabIndex == 0 
          ? _buildChildrenCardsTab(provider) 
          : _buildNotificationsTab(provider),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        selectedItemColor: Colors.teal[700],
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontFamily: "Cairo"),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: "الأبناء"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: "الإشعارات"),
        ],
      ),
    );
  }

  // =========================================================================
  // 1. بناء واجهة الأبناء كـ كروت مبسطة (بديل الكود العملاق)
  // =========================================================================
  Widget _buildChildrenCardsTab(GuardianProvider provider) {
    if (provider.loading && provider.children.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    if (provider.error != null && provider.children.isEmpty) {
      return _buildErrorWidget(provider.error!, () => provider.loadChildren());
    }

    if (provider.children.isEmpty) {
      return _buildEmptyState("لا يوجد أبناء مسجلون مرتبطون بحسابك حالياً.");
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadChildren(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,         // عرض كرتين في كل صف لتصميم عصري متوازن
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.85,    // تناسب الطول والعرض للكرت
        ),
        itemCount: provider.children.length,
        itemBuilder: (context, index) {
          final child = provider.children[index];
          
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // 🎯 إدارة الحالة النظيفة: نقوم باختيار الابن وشحن بياناته التفصيلية فوراً
                provider.loadChildData(child.id);
                // الانتقال التلقائي لشاشة لوحة التحكم الخاصة بهذا الابن
                Navigator.pushNamed(context, "/guardian-child-dashboard");
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.teal[50],
                      child: Icon(Icons.face_rounded, size: 40, color: Colors.teal[700]),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      child.fullName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 14, height: 1.3),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "اضغط للمتابعة",
                      style: TextStyle(fontFamily: "Cairo", fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // 2. تابع مركز الإشعارات (كما هو في ملفك الأصلي دون تعديل)
  // =========================================================================
  Widget _buildNotificationsTab(GuardianProvider provider) {
    if (provider.loading && provider.notifications.isEmpty) return const Center(child: CircularProgressIndicator());
    if (provider.notifications.isEmpty) return _buildEmptyState("مركز الإشعارات فارغ حالياً.");

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
              title: Text(item.title, style: TextStyle(fontFamily: "Cairo", fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold, color: item.isRead ? Colors.black87 : Colors.teal[900])),
              subtitle: Text(item.message, style: const TextStyle(fontFamily: "Cairo", fontSize: 13, color: Colors.black54)),
              trailing: !item.isRead
                  ? IconButton(icon: const Icon(Icons.done_all_rounded, color: Colors.teal), onPressed: () => provider.markNotificationAsRead(item.id))
                  : const Icon(Icons.check_circle_outline_rounded, color: Colors.grey, size: 18),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(error, style: const TextStyle(fontFamily: "Cairo", color: Colors.red)),
          TextButton(onPressed: onRetry, child: const Text("إعادة المحاولة", style: TextStyle(fontFamily: "Cairo"))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(message, style: const TextStyle(fontFamily: "Cairo", color: Colors.grey)),
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
}