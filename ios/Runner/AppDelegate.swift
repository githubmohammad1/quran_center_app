import Flutter
import UIKit
import UserNotifications // 🚀 مكتبة أساسية للتحكم بلوحة الإشعارات بدون حزم خارجية

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // إعداد جذر الواجهة والقناة البرمجية بالتوافق مع اسم الـ Package
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.example.quran_center_app/notifications",
                                      binaryMessenger: controller.binaryMessenger)
    
    // معالجة الحدث القادم من جهة تطبيق Flutter
    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "clearNotifications" {
        // 1. تصفير الرقم (Badge) الموجود فوق أيقونة التطبيق
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // 2. مسح الإشعارات المستلمة من صندوق الإشعارات العلوي
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
        result(true)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}