import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:quran_center_app/presentation/providers/teacher_provider.dart';
import 'package:quran_center_app/data/models/person_model.dart';

class TeacherQRScannerScreen extends StatefulWidget {
  final int? activeHalqaId; // تمرير رقم الحلقة الحالية لتأمين سياق الحضور والتسميع

  const TeacherQRScannerScreen({Key? key, this.activeHalqaId}) : super(key: key);

  @override
  State<TeacherQRScannerScreen> createState() => _TeacherQRScannerScreenState();
}

class _TeacherQRScannerScreenState extends State<TeacherQRScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates, // حماية أولية من التكرار
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  /// معالجة الرمز المقروء وتطبيق منطق الجودة الميداني
  void _onQrCodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

    final String rawCode = barcodes.first.rawValue!;
    
    setState(() => _isProcessing = true);
    // 🛠️ جودة: إيقاف الكاميرا مؤقتاً فوراً لمنع توالي القراءات المزعجة للشيخ
    await _cameraController.stop(); // 

    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false); // 
    
    // 🔍 البحث المحلي السريع عن هوية الطالب
    final PersonModel? student = teacherProvider.findStudentByQrCode(rawCode);

    if (student == null) {
      _showErrorBottomSheet("⚠️ عذراً، هذا الرمز غير مسجل أو أن الطالب لا ينتمي لحلقتك الحالية.");
    } else {
      // 🎯 التوجيه الذكي: تم العثور على الطالب، اعرض لوحة التحكم السريعة له
      _showSmartRoutingBottomSheet(student, teacherProvider); // 
    }
  }

  /// منبثق التوجيه الذكي لإدارة الحضور أو التسميع الفوري
  void _showSmartRoutingBottomSheet(PersonModel student, TeacherProvider provider) { // [cite: 23, 27]
    showModalBottomSheet(
      context: context,
      isDismissible: false, // إجبار المعلم على اتخاذ قرار أو الإغلاق المنظم لإعادة الكاميرا
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // رأسية المنبثق تظهر بيانات الطالب المتعرف عليه
              Text(
                student.fullName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              Text(
                "رقم المعرّف الميداني: ${student.id}",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              
              // الخيار الأول: تسجيل حضور فوري تلقائي
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.check_circle, color: Colors.green.shade700),
                ),
                title: const Text("تسجيل حضور فوري (حاضر)", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("سيتم تدوينه في سجلات اليوم وتحديث السيرفر مباشرة"),
                onTap: () async {
                  Navigator.pop(context); // إغلاق الـ BottomSheet
                  
                  // افتراض الحلقة النشطة الأولى إذا لم تمرر كـ Argument لسلامة الواجهة
                  final int targetHalqaId = widget.activeHalqaId ?? 
                      (provider.myHalqas.isNotEmpty ? provider.myHalqas.first.id : 0); // [cite: 28]

                  bool success = await provider.registerImmediateAttendance(student.id, targetHalqaId, "PRESENT");
                  
                  if (success) {
                    _showTemporarySuccessSnackBar("✅ تم تسجيل حضور ${student.fullName} بنجاح.");
                  } else {
                    _showTemporarySuccessSnackBar("⚠️ ${provider.error ?? 'فشل في حفظ الحضور'}"); // [cite: 30]
                  }
                  _resumeScanning(); // إعادة تشغيل الكاميرا لاستقبال الطالب التالي
                },
              ),
              const Divider(height: 20),
              
              // الخيار الثاني: فتح شاشة التسميع المشتركة مع التمرير التلقائي للبيانات
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.amber.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.menu_book, color: Colors.amber.shade800),
                ),
                title: const Text("انتقال للتسميع اليومي فورا", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("يفتح شاشة التدوين مع تعبئة بيانات الطالب تلقائياً توفيراً للوقت"),
                onTap: () {
                  Navigator.pop(context); // إغلاق الـ BottomSheet
                  
                  // التوجيه عبر المسار المشترك والمحصن الذي اعتمدناه
                  Navigator.pushNamed(
                    context,
                    "/shared-add-memorization",
                    arguments: {
                      "student": student, // تمرير كائن الطالب المكتشف
                      "halqa_id": widget.activeHalqaId ?? (provider.myHalqas.isNotEmpty ? provider.myHalqas.first.id : 0) // [cite: 28]
                    },
                  ).then((_) {
                    // عند العودة من شاشة التسميع، أعد تشغيل الكاميرا تلقائياً لالتقاط الطالب التالي
                    _resumeScanning();
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // زر إلغاء العمل الحالي وإعادة المسح
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resumeScanning();
                },
                child: const Text("إلغاء وإعادة مسح", style: TextStyle(color: Colors.red, fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  /// إعادة تشغيل الكاميرا بوضع نظيف
  void _resumeScanning() async {
    setState(() => _isProcessing = false);
    await _cameraController.start(); // 
  }

  /// منبثق الخطأ في حال لم يكن الطالب مسجلاً بالحلقة
  void _showErrorBottomSheet(String message) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(message, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resumeScanning();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text("مفهوم، أعد المحاولة"),
              )
            ],
          ),
        );
      },
    );
  }

  void _showTemporarySuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ماسح الرموز الميداني (QR)"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // نافذة الكاميرا الحية للمسح
          MobileScanner(
            controller: _cameraController,
            onDetect: _onQrCodeDetected,
          ),
          
          // المظهر الجمالي المربع فوق الكاميرا لإرشاد الشيخ لموضع الرمز
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal.shade400, width: 4),
                borderRadius: BorderRadius.circular(24),
                color: Colors.black26,
              ),
            ),
          ),
          
          const Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Text(
              "قم بتوجيه الكاميرا نحو الرمز الرقمي لبطاقة الطالب",
              style: TextStyle(color: Colors.white, fontSize: 16, backgroundColor: Colors.black54, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}