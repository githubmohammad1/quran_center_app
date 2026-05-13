import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // طلب الإذن
    await _firebaseMessaging.requestPermission();

    // الحصول على FCM Token
    final token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    // استقبال الإشعارات أثناء فتح التطبيق
    FirebaseMessaging.onMessage.listen((message) {
      print("📩 إشعار أثناء الاستخدام: ${message.notification?.title}");
    });

    // استقبال الإشعارات عند الضغط عليها
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("📩 فتح التطبيق من إشعار: ${message.notification?.title}");
    });
  }
}
