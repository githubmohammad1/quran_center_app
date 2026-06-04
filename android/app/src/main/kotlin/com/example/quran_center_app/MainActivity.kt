package com.example.quran_center_app

import android.app.NotificationManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // اسم القناة المعياري والمطابق لحزمة مشروعك
    private val CHANNEL = "com.example.quran_center_app/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // ربط القناة واستقبال أمر المسح والتصفيير من Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "clearNotifications") {
                try {
                    val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    notificationManager.cancelAll() // يمسح صندوق الإشعارات ويخفي شارة الأيقونة تلقائياً
                    result.success(true)
                } catch (e: Exception) {
                    result.error("NATIVE_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}