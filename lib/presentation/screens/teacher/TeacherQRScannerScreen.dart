import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:quran_center_app/presentation/providers/teacher_provider.dart';
import 'package:quran_center_app/data/models/person_model.dart';

class TeacherQRScannerScreen extends StatefulWidget {
  final int? activeHalqaId;

  const TeacherQRScannerScreen({Key? key, this.activeHalqaId}) : super(key: key);

  @override
  State<TeacherQRScannerScreen> createState() => _TeacherQRScannerScreenState();
}

class _TeacherQRScannerScreenState extends State<TeacherQRScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // ============================================================
  // 🔍 معالجة الرمز المقروء
  // ============================================================
  void _onQrCodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

    final String rawCode = barcodes.first.rawValue!;
    await _processStudentCode(rawCode);
  }

  // ============================================================
  // 🔍 معالجة رقم الطالب سواء من QR أو إدخال يدوي
  // ============================================================
  Future<void> _processStudentCode(String rawCode) async {
    setState(() => _isProcessing = true);
    await _cameraController.stop();

    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);

    // البحث عن الطالب
    final PersonModel? student = teacherProvider.findStudentByQrCode(rawCode.trim());

    if (student == null) {
      _showErrorBottomSheet("⚠️ لا يوجد طالب بهذا الرقم أو لا ينتمي لحلقتك.");
      return;
    }

    // تسجيل حضور تلقائي
    final int targetHalqaId = widget.activeHalqaId ??
        (teacherProvider.myHalqas.isNotEmpty ? teacherProvider.myHalqas.first.id : 0);

    final today = DateTime.now();
    final formattedDate =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    bool success = await teacherProvider.saveAttendance({
      "student": student.id,
      "halqa": targetHalqaId,
      "status": "present",
      "date": formattedDate,
    });

    if (!success) {
      _showTemporarySuccessSnackBar(
        "⚠️ ${teacherProvider.error ?? 'فشل في تسجيل الحضور'}",
      );
      _resumeScanning();
      return;
    }

    // الانتقال لشاشة التسميع
    Navigator.pushNamed(
      context,
      "/shared-add-memorization",
      arguments: {
        "student": student,
        "halqa_id": targetHalqaId,
      },
    ).then((_) => _resumeScanning());
  }

  // ============================================================
  // ▶️ إعادة تشغيل الكاميرا
  // ============================================================
  void _resumeScanning() async {
    setState(() => _isProcessing = false);
    await _cameraController.start();
  }

  // ============================================================
  // ❌ منبثق الخطأ
  // ============================================================
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
              Text(
                message,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resumeScanning();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("مفهوم، أعد المحاولة"),
              )
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ✔️ SnackBar نجاح أو فشل
  // ============================================================
  void _showTemporarySuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  // ============================================================
  // ✏️ إدخال رقم الطالب يدويًا
  // ============================================================
  void _showManualEntryDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("إدخال رقم الطالب"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "أدخل رقم الطالب",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resumeScanning();
              },
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                final code = controller.text.trim();
                if (code.isNotEmpty) {
                  _processStudentCode(code);
                }
              },
              child: const Text("متابعة"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // 🖥️ واجهة المستخدم
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ماسح الرموز الميداني (QR)"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: "إدخال رقم الطالب يدويًا",
            onPressed: _showManualEntryDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: _onQrCodeDetected,
          ),

          // إطار التوجيه
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
              "قم بتوجيه الكاميرا نحو الرمز الرقمي أو أدخل رقم الطالب يدويًا",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                backgroundColor: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
