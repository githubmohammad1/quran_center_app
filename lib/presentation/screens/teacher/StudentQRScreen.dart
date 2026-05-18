import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quran_center_app/data/models/person_model.dart';

class StudentQRScreen extends StatelessWidget {
  final PersonModel student;

  const StudentQRScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR — ${student.fullName}"),
      ),
      body: Center(
        child: QrImageView(
          data: student.id.toString(),   // ← رقم الطالب فقط
          size: 260,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
