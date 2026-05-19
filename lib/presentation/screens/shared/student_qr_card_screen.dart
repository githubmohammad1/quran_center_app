import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quran_center_app/data/models/person_model.dart';

class StudentQRCardScreen extends StatefulWidget {
  final PersonModel student;

  const StudentQRCardScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<StudentQRCardScreen> createState() => _StudentQRCardScreenState();
}

class _StudentQRCardScreenState extends State<StudentQRCardScreen> {
  bool _isSharing = false;

  Future<void> _shareQrCode() async {
    final String? qrUrl = widget.student.qrCode;

    if (qrUrl == null || qrUrl.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ لا يوجد رمز QR متاح")),
        );
      }
      return;
    }

    if (kIsWeb) {
      try {
        final Uri url = Uri.parse(qrUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("تعذر فتح الرابط في المتصفح")),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("تعذر فتح الرابط: $e")),
          );
        }
      }
      return;
    }

    if (mounted) setState(() => _isSharing = true);
    try {
      final tempDir = await getTemporaryDirectory();
      final safeName = widget.student.fullName
          .replaceAll(RegExp(r'[^\w\s\-]'), '_')
          .replaceAll(' ', '_');
      final filePath = "${tempDir.path}/QR_$safeName.png";

      await Dio().download(qrUrl, filePath);

      final xfile = XFile(filePath, mimeType: 'image/png');
      await Share.shareXFiles(
        [xfile],
        text:
            "بطاقة الطالب الرقمية: ${widget.student.fullName}\nجامع عثمان - مدرسة الخولاني",
      );
    } catch (e, st) {
      debugPrint("shareQrCode error: $e\n$st");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تعذر الإرسال: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      // الاسم
                      Text(
                        widget.student.fullName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),

                      // رقم الطالب
                      Text(
                        "ID: ${widget.student.id}",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),

                      const SizedBox(height: 20),

                      // مربع QR مع رقم ID في الزاوية
                      Stack(
                        children: [
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

                          // رقم ID في الزاوية
                         
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Text("جامع عثمان", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

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
