// services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/student_providers.dart';

class NotificationService {
  
  static Future<void> initialize(GlobalKey<NavigatorState> navKey) async {
    await FirebaseMessaging.instance.requestPermission();

    // =========================================================================
    // 1) التتبع في حالة الفتح (Foreground): التطبيق نشط بين يديك الآن
    // =========================================================================
    FirebaseMessaging.onMessage.listen((message) {
      print("\n================ 📥 FOREGROUND NOTIFICATION RECEIVED ================");
      print("🔔 Title: ${message.notification?.title}");
      print("📄 Body: ${message.notification?.body}");
      print("📦 Payload Data (Django): ${message.data}");
      print("====================================================================\n");
      
      final context = navKey.currentContext;
      if (context != null) {
        try {
          context.read<StudentProvider>().loadAll(); 
        } catch (e) {
          print("⚠️ Provider Refresh Error: $e");
        }
      }
    });

    // =========================================================================
    // 2) التتبع في حالة الخلفية (Background): ضغطت على الإشعار والتطبيق بالخلفية
    // =========================================================================
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("\n================ 📱 BACKGROUND NOTIFICATION CLICKED ================");
      print("📦 Clicked Payload Data: ${message.data}");
      print("====================================================================\n");
      
      _handleRoutingAndAction(message.data, navKey);
    });

    // =========================================================================
    // 3) التتبع في حالة الإغلاق (Terminated): ضغطت على الإشعار والتطبيق مغلق تماماً
    // =========================================================================
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("\n================ 🚀 TERMINATED NOTIFICATION LAUNCH ================");
      print("📦 Initial Payload Data: ${initialMessage.data}");
      print("====================================================================\n");
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleRoutingAndAction(initialMessage.data, navKey);
      });
    }
  }

  static void _handleRoutingAndAction(Map<String, dynamic> data, GlobalKey<NavigatorState> navKey) {
    final context = navKey.currentContext;
    if (context == null) return;

    final category = data["category"];
    final notificationId = data["notification_id"];

    // طباعة تأكيدية إضافية لرصد معالجة البيانات قبل التوجيه الفعلي للشاشات
    print("🛠️ Route Dispatcher -> Category: $category | Notification ID: $notificationId");

    if (notificationId != null) {
      try {
        context.read<StudentProvider>().markNotificationAsRead(
          int.parse(notificationId),
        );
      } catch (e) {
        print("⚠️ Parsing Error: $e");
      }
    }

    if (category == "MEMORIZATION") {
      Navigator.pushNamed(context, "/student-progress");
    } else if (category == "ATTENDANCE") {
      Navigator.pushNamed(context, "/student-attendance");
    } else if (category == "TEST") { 
      Navigator.pushNamed(context, "/student-tests");
    } else {
      Navigator.pushNamed(context, "/student-notifications");
    }
  }
}