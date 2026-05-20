import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../presentation/providers/student_providers.dart';

class NotificationService {
  static Future<void> initialize(GlobalKey<NavigatorState> navKey) async {
    if (kIsWeb) return;

    await FirebaseMessaging.instance.requestPermission();

    // ============= 1) استقبال الإشعار أثناء فتح التطبيق =============
    FirebaseMessaging.onMessage.listen((message) {
      final context = navKey.currentContext;
      if (context != null) {
        context.read<StudentProvider>().loadAll();
      }
    });

    // ============= 2) فتح التطبيق من الإشعار =============
   FirebaseMessaging.onMessageOpenedApp.listen((message) {
  final context = navKey.currentContext;
  if (context == null) return;

  final data = message.data;
  final category = data["category"];
  final notificationId = data["notification_id"];

  // تعليم الإشعار كمقروء
  if (notificationId != null) {
    context.read<StudentProvider>().markNotificationAsRead(int.parse(notificationId));
  }

  // فتح الشاشة المناسبة حسب نوع الإشعار
  if (category == "MEMORIZATION") {
    Navigator.pushNamed(context, "/student-progress");
  } 
  else if (category == "ATTENDANCE") {
    Navigator.pushNamed(context, "/student-attendance");
  } 
  else if (category == "SUCCESS") {
    Navigator.pushNamed(context, "/student-tests");
  } 
  else {
    Navigator.pushNamed(context, "/student-notifications");
  }
});


    // ============= 3) عند تشغيل التطبيق من إشعار مغلق =============
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final context = navKey.currentContext;
      if (context != null) {
        final data = initialMessage.data;
        final category = data["category"];
        final notificationId = data["notification_id"];

        if (notificationId != null) {
          context.read<StudentProvider>().markNotificationAsRead(int.parse(notificationId));
        }

        if (category == "MEMORIZATION") {
          Navigator.pushNamed(context, "/student-progress");
        } else if (category == "ATTENDANCE") {
          Navigator.pushNamed(context, "/student-attendance");
        } else if (category == "SUCCESS") {
          Navigator.pushNamed(context, "/student-tests");
        } else {
          Navigator.pushNamed(context, "/student-notifications");
        }
      }
    }
  }
}
