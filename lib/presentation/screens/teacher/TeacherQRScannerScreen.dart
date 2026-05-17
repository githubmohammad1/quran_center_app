import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:quran_center_app/data/models/person_model.dart';


class TeacherQRScannerScreen extends StatefulWidget {
  const TeacherQRScannerScreen({super.key});

  @override
  State<TeacherQRScannerScreen> createState() => _TeacherQRScannerScreenState();
}

class _TeacherQRScannerScreenState extends State<TeacherQRScannerScreen> {
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مسح QR للطالب"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (isProcessing) return;

              if (capture.barcodes.isEmpty) return;
final barcode = capture.barcodes.first;

              final raw = barcode.rawValue;

              if (raw != null) {
                isProcessing = true;
                _handleScan(raw);
              }
            },
          ),

          // إطار جميل للكاميرا
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // معالجة البيانات القادمة من QR
  // ---------------------------------------------------------
  void _handleScan(String raw) {
    try {
      final data = jsonDecode(raw);

      final student = PersonModel.fromJson(data);

    Navigator.pushReplacementNamed(
  context,
  "/teacher-dashboard");

    } catch (e) {
      isProcessing = false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("QR غير صالح")),
      );
    }
  }
}
