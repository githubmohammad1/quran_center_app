import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quran_center_app/data/models/person_model.dart';

class StudentQRCardScreen extends StatefulWidget {
  final PersonModel student;

  const StudentQRCardScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<StudentQRCardScreen> createState() => _StudentQRCardScreenState();
}

class _StudentQRCardScreenState extends State<StudentQRCardScreen> {
  bool _isSharing = false;

  /// دالة المشاركة: تقوم بتحميل الصورة محلياً ثم مشاركتها (أكثر احترافية واستقراراً)
  Future<void> _shareQrCode() async {
    final String? qrUrl = widget.student.qrCode;
    
    if (qrUrl == null || qrUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ لا يوجد رمز QR متاح للمشاركة")),
      );
      return;
    }

    setState(() => _isSharing = true);

    try {
      final tempDir = await getTemporaryDirectory();
      final String filePath = "${tempDir.path}/QR_${widget.student.id}.png";
      
      // تحميل الصورة محلياً لضمان جودة المشاركة
      await Dio().download(qrUrl, filePath);

      // مشاركة الملف
      await Share.shareXFiles([XFile(filePath)], text: "بطاقة الطالب: ${widget.student.fullName}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في المشاركة: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 استهلاك مباشر للرابط الجاهز القادم من الـ Repo (بدون أي معالجة هنا)
    final String fullQrUrl = widget.student.qrCode ?? "";
    final bool hasQr = fullQrUrl.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text("بطاقة الطالب الرقمية")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(widget.student.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      
                      // 🖼️ عرض الصورة (الرابط هنا مطلق ومجهز مسبقاً في الـ Repo)
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: hasQr
                            ? Image.network(
                                fullQrUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => 
                                    const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.red)),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                              )
                            : const Center(child: Text("لا يوجد رمز QR")),
                      ),
                      const SizedBox(height: 16),
                      const Text("جامع عثمان - مدرسة الخولاني", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // زر المشاركة
              _isSharing 
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: hasQr ? _shareQrCode : null,
                    icon: const Icon(Icons.share),
                    label: const Text("مشاركة البطاقة"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}