// services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🚀 تحديث جودة: استيراد ضروري لتفعيل القنوات الأصيلة (MethodChannel)
import 'package:provider/provider.dart';
import '../presentation/providers/student_providers.dart';

/// دالة معالجة الرسائل في الخلفية (Background Message Handler)
/// يجب أن تكون دالة علوية (Top-level Function) وخارج سياق الكلاس لتعمل في عملية منفصلة (Isolate)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("\n================ 💤 BACKGROUND/TERMINATED EVENT RECEIVED ================");
  print("🆔 Message ID: ${message.messageId}");
  print("📦 Background Payload Data: ${message.data}");
  print("========================================================================\n");
}

class NotificationService {
  // 🚀 تعريف القناة الأصيلة الموحدة والمطابقة 100% مع أندرويد وآيفون
  static const _nativeChannel = MethodChannel('com.example.quran_center_app/notifications');

  /// 🧹 الممحاة المركزية: تفجير ومسح الإشعارات المعلقة وتصفير شارات الأيقونة عبر الـ Native Channel
  static Future<void> clearAllNotifications() async {
    try {
      await _nativeChannel.invokeMethod('clearNotifications');
      print("🧹 [FCM CLEANER] Notification tray and badges cleared successfully via Native Channel.");
    } catch (e) {
      print("⚠️ [FCM CLEANER] Failed to clear notifications via Native Channel: $e");
    }
  }
  
  static Future<void> initialize(GlobalKey<NavigatorState> navKey) async {
    // 1. طلب صلاحيات نظام التشغيل بشكل رسمي
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print("📋 [FCM SETUP] Notification Authorization Status: ${settings.authorizationStatus}");

    // 2. تسجيل دالة الاستماع في الخلفية المطلقة (Background Handler)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 🔗 حزام أمان (1): مسح الإشعارات التراكمية القديمة فور تشغيل التطبيق من الصفر
    await clearAllNotifications();

    // =========================================================================
    // 1) التتبع وحل مشكلة الفتح (Foreground): التطبيق نشط ومفتوح حالياً
    // =========================================================================
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("\n================ 📥 FOREGROUND NOTIFICATION FLOW ================");
      print("🔔 Title: ${message.notification?.title}");
      print("📄 Body: ${message.notification?.body}");
      print("📦 Payload Data (Django): ${message.data}");
      print("====================================================================\n");
      
      final context = navKey.currentContext;
      if (context != null) {
        // أ) تحديث البيانات تلقائياً في الخلفية البرمجية عبر الـ Provider
        try {
          context.read<StudentProvider>().loadAll(); 
          print("🔄 [FCM FOREGROUND] Provider state synced successfully.");
        } catch (e) {
          print("⚠️ [FCM FOREGROUND] Provider Refresh Error: $e");
        }

        // ب) الحل الهندسي الذكي: إظهار بطاقة بصرية (Visual Banner) للمستخدم داخل التطبيق
        if (message.notification != null) {
          _showInAppNotificationBanner(context, message.notification!, message.data, navKey);
        }
      }
    });

    // =========================================================================
    // 2) التتبع في حالة الخلفية (Background): الضغط على الإشعار والتطبيق بالخلفية
    // =========================================================================
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("\n================ 📱 BACKGROUND NOTIFICATION CLICKED ================");
      print("📦 Clicked Payload Data: ${message.data}");
      print("====================================================================\n");
      
      // 🔗 حزام أمان (2): مسح اللوحة والشارات فور نقر الإشعار من الخلفية
      await clearAllNotifications();
      _handleRoutingAndAction(message.data, navKey);
    });

    // =========================================================================
    // 3) التتبع في حالة الإغلاق (Terminated): الضغط على الإشعار والتطبيق مغلق تماماً
    // =========================================================================
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("\n================ 🚀 TERMINATED NOTIFICATION LAUNCH ================");
      print("📦 Initial Payload Data: ${initialMessage.data}");
      print("====================================================================\n");
      
      // 🔗 حزام أمان (3): مسح اللوحة والشارات فور نقر الإشعار والتطبيق مغلق تماماً
      await clearAllNotifications();
      
      // ننتظر استقرار بنية شجرة الشاشات بشكل كامل وآمن قبل بدء التوجيه
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleRoutingAndAction(initialMessage.data, navKey);
      });
    }
  }

  /// دالة عرض بطاقة الإشعار داخل التطبيق عند استقباله والتطبيق مفتوح (In-App Banner)
  static void _showInAppNotificationBanner(
      BuildContext context, RemoteNotification notification, Map<String, dynamic> data, GlobalKey<NavigatorState> navKey) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ListTile(
          leading: const Icon(Icons.star_rounded, color: Colors.amber, size: 30),
          title: Text(
            notification.title ?? "إشعار جديد",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          subtitle: Text(
            notification.body ?? "",
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
          contentPadding: EdgeInsets.zero,
        ),
        backgroundColor: const Color(0xFF1E1E2E), // ثيم غامق فاخر يناسب هوية مركز القرآن
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: "عرض",
          textColor: Colors.amber,
          onPressed: () async {
            // 🔗 حزام أمان (4): مسح اللوحة والشارات عند تفاعل المستخدم الفوري مع الـ SnackBar
            await clearAllNotifications();
            _handleRoutingAndAction(data, navKey);
          },
        ),
      ),
    );
  }

  /// الدالة الموحدة والمحمية لإدارة التوجيه وتعليم الإشعار كمقروء
  static void _handleRoutingAndAction(Map<String, dynamic> data, GlobalKey<NavigatorState> navKey) {
    final context = navKey.currentContext;
    if (context == null) {
      print("❌ [FCM ROUTER] Cancelled. Context is unavailable.");
      return;
    }

    final category = data["category"];
    final notificationId = data["notification_id"];

    print("🛠️ [FCM ROUTER] Processing Action -> Category: $category | Notification ID: $notificationId");

    // 1. التحديث الآمن لحالة المقروئية مع حماية معالجة الأنواع (Type Safety Guard)
    if (notificationId != null) {
      try {
        final parsedId = int.tryParse(notificationId.toString());
        if (parsedId != null) {
          context.read<StudentProvider>().markNotificationAsRead(parsedId);
          print("✅ [FCM ROUTER] Marked notification #$parsedId as read.");
        } else {
          print("⚠️ [FCM ROUTER] Skipped marking read: notification_id is not a valid integer.");
        }
      } catch (e) {
        print("⚠️ [FCM ROUTER] Failed to execute markNotificationAsRead: $e");
      }
    }

    // 2. التوجيه الموحد والمعزز بمطابقة 100% مع الباك إند
    String targetRoute = "/student-notifications"; // المسار الافتراضي (Fallback)

    if (category == "MEMORIZATION") {
      targetRoute = "/student-progress";
    } else if (category == "ATTENDANCE") {
      targetRoute = "/student-attendance";
    } else if (category == "TEST") { 
      targetRoute = "/student-tests";
    }

    // التوجيه مع منع التكرار ومراقبة التسلسل
    print("🚀 [FCM ROUTER] Pushing Route: $targetRoute");
    Navigator.pushNamed(context, targetRoute);
  }
}