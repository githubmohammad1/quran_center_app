import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/data/models/halqa_model.dart';
import '../../providers/teacher_provider.dart';


class TeacherHalqaStudentsScreen extends StatefulWidget {
  final HalqaModel halqa;

  const TeacherHalqaStudentsScreen({super.key, required this.halqa});

  @override
  State<TeacherHalqaStudentsScreen> createState() => _TeacherHalqaStudentsScreenState();
}

class _TeacherHalqaStudentsScreenState extends State<TeacherHalqaStudentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherProvider>().loadHalqaStudents(widget.halqa.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text("طلاب حلقة ${widget.halqa.name}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FA), Color(0xFFF1F3F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : provider.currentHalqaStudents.isEmpty
                ? const Center(child: Text("لا يوجد طلاب في هذه الحلقة"))
                : ListView.builder(
                    itemCount: provider.currentHalqaStudents.length,
                    itemBuilder: (context, index) {
                      final student = provider.currentHalqaStudents[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: _box(),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(Icons.person, color: Colors.blue.shade700),
                            ),
                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.fullName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "رقم الطالب: ${student.id}",
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),

                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == "memorization") {
                               Navigator.pushNamed(
  context,
  "/teacher-add-memorization",
  arguments: {
    "student": student,
    "halqa": widget.halqa,
  },
);

                                } else if (value == "attendance") {
                                  Navigator.pushNamed(
                                    context,
                                    "/teacher-attendance",
                                    arguments: student,
                                  );
                                } else if (value == "test") {
                                  Navigator.pushNamed(
                                    context,
                                    "/teacher-add-test",
                                    arguments: student,
                                  );
                                } else if (value == "qr") {
                                  Navigator.pushNamed(
                                    context,
                                    "/teacher-student-qr",
                                    arguments: student,
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: "memorization",
                                  child: Text("تسجيل تسميع"),
                                ),
                                const PopupMenuItem(
                                  value: "attendance",
                                  child: Text("تسجيل حضور"),
                                ),
                                const PopupMenuItem(
                                  value: "test",
                                  child: Text("تسجيل اختبار"),
                                ),
                                const PopupMenuItem(
                                  value: "qr",
                                  child: Text("عرض QR للطالب"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  // صندوق تصميم موحد
  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
