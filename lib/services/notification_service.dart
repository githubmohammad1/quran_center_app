import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static Future<void> initialize() async {
    if (kIsWeb) {
      print("🔕 Notifications disabled on Web");
      return;
    }

    await FirebaseMessaging.instance.requestPermission();

    final token = await FirebaseMessaging.instance.getToken();
    print("🔥 FCM Token: $token");

    FirebaseMessaging.onMessage.listen((message) {
      print("📩 إشعار أثناء الاستخدام: ${message.notification?.title}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("📩 فتح التطبيق من إشعار: ${message.notification?.title}");
    });
  }
}
