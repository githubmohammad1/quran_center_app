import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/data/models/halqa_model.dart';
import '../../providers/teacher_provider.dart';

class TeacherHalqaStudentsScreen extends StatefulWidget {
  final HalqaModel halqa;

  const TeacherHalqaStudentsScreen({super.key, required this.halqa});

  @override
  State<TeacherHalqaStudentsScreen> createState() =>
      _TeacherHalqaStudentsScreenState();
}

class _TeacherHalqaStudentsScreenState
    extends State<TeacherHalqaStudentsScreen> {
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("طلاب الحلقة", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(
              widget.halqa.name,
              style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.loadHalqaStudents(widget.halqa.id),
          ),
        ],
      ),
      body: provider.isProgressLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.currentHalqaStudents.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => provider.loadHalqaStudents(widget.halqa.id),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.currentHalqaStudents.length,
                    itemBuilder: (context, index) {
                      final student = provider.currentHalqaStudents[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: _boxDecoration(),
                        child: Material(
                          color: Colors.transparent,
                          child: ExpansionTile(
                            shape: const RoundedRectangleBorder(side: BorderSide.none),
                            collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                            
                            // --- الجزء العلوي للبطاقة: بيانات الطالب الأساسية ---
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue.shade50,
                              child: Text(
                                student.fullName.isNotEmpty ? student.fullName.substring(0, 1) : "ط",
                                style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            title: Text(
                              student.fullName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "ID: ${student.id}",
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: _buildSecondaryMenu(student),

                            // --- الجزء السفلي المستحدث: الإجراءات السريعة والظاهرة للتفاعل المباشر ---
                            children: [
                              const Divider(height: 1, thickness: 0.5, color: Color(0xFFE0E0E0)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  // زر تسجيل التسميع (بارز وتفاعلي بنقرة واحدة)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _navigateTo("/shared-add-memorization", student),
                                      icon: const Icon(Icons.menu_book_rounded, size: 18),
                                      label: const Text("تسجيل تسميع"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // زر تسجيل الحضور (بارز وتفاعلي بنقرة واحدة)
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _navigateTo("/teacher-attendance", student),
                                      icon: Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.blue.shade700),
                                      label: Text("تسجيل حضور", style: TextStyle(color: Colors.blue.shade800)),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.blue.shade300),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  // دالة الملاحة الموحدة لتخفيف تكرار الكود الميت
  void _navigateTo(String route, dynamic student) {
    print( student);
    Navigator.pushNamed(
      context,
      route,
      arguments: {
        "student": student,
        "halqa": widget.halqa,
      },
    );
  }

  // قائمة الخيارات المنبثقة للعمليات الثانوية المتبقية
  Widget _buildSecondaryMenu(dynamic student) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.black54),
      onSelected: (value) {
        if (value == "test") _navigateTo("/teacher-add-test", student);
        if (value == "qr") _navigateTo("/shared-student-qr", student);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: "test",
          child: Row(
            children: [
              Icon(Icons.fact_check_rounded, size: 18, color: Colors.orange),
              SizedBox(width: 10),
              Text("تسجيل اختبار أجزاء"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: "qr",
          child: Row(
            children: [
              Icon(Icons.qr_code_2_rounded, size: 18, color: Colors.purple),
              SizedBox(width: 10),
              Text("عرض رمز الـ QR"),
            ],
          ),
        ),
      ],
    );
  }

  // واجهة تعبيرية عند خلو الحلقة من الطلاب
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "لا يوجد طلاب مضافين في هذه الحلقة حالياً.",
            style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // تصميم الحاوية الخارجي لضمان الانسيابية والظلال الناعمة
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}