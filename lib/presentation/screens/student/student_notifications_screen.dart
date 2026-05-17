import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_providers.dart';

class StudentNotificationsScreen extends StatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  State<StudentNotificationsScreen> createState() => _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState extends State<StudentNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل كل بيانات الطالب (بما فيها الإشعارات)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("الإشعارات"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFF1F3F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : provider.notifications.isEmpty
                ? const Center(child: Text("لا توجد إشعارات"))
                : RefreshIndicator(
                    onRefresh: () async => provider.loadAll(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.notifications.length,
                      itemBuilder: (context, index) {
                        final n = provider.notifications[index];
                        return _notificationCard(context, provider, n);
                      },
                    ),
                  ),
      ),
    );
  }

  // ---------------------------------------------------------
  // بطاقة الإشعار
  // ---------------------------------------------------------
  Widget _notificationCard(BuildContext context, StudentProvider provider, notification) {
    final isRead = notification.isRead;

    Color categoryColor;
    IconData categoryIcon;

    switch (notification.category) {
      case "MEMORIZATION":
        categoryColor = Colors.blue;
        categoryIcon = Icons.menu_book;
        break;
      case "TEST":
        categoryColor = Colors.orange;
        categoryIcon = Icons.fact_check;
        break;
      case "ATTENDANCE":
        categoryColor = Colors.green;
        categoryIcon = Icons.calendar_today;
        break;
      case "SUCCESS":
        categoryColor = Colors.purple;
        categoryIcon = Icons.star;
        break;
      default:
        categoryColor = Colors.grey;
        categoryIcon = Icons.notifications;
    }

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          provider.markNotificationAsRead(notification.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.green.shade50.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isRead
                ? Colors.black.withValues(alpha: 0.05)
                : Colors.green.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: categoryColor.withValues(alpha: 0.15),
              child: Icon(categoryIcon, color: categoryColor, size: 28),
            ),
            const SizedBox(width: 16),

            // النصوص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.createdAt,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // نقطة حالة القراءة
            if (!isRead)
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
