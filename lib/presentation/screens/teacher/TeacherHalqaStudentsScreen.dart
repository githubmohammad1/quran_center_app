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
    extends State<TeacherHalqaStudentsScreen> with TickerProviderStateMixin {
  AnimationController? _fadeController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<TeacherProvider>().loadHalqaStudents(widget.halqa.id);

      if (mounted) {
        _fadeController?.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.black87,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("طلاب الحلقة",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(
              widget.halqa.name,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                provider.loadHalqaStudents(widget.halqa.id),
          ),
        ],
      ),
      body: provider.isStudentsLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.currentHalqaStudents.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () =>
                      provider.loadHalqaStudents(widget.halqa.id),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.currentHalqaStudents.length,
                    itemBuilder: (context, index) {
                      final student = provider.currentHalqaStudents[index];

                      // حماية من null
                      if (_fadeController == null) {
                        return _buildStudentCard(student);
                      }

                      final animation = Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _fadeController!,
                          curve: Curves.easeOut,
                        ),
                      );

                      return FadeTransition(
                        opacity: _fadeController!,
                        child: SlideTransition(
                          position: animation,
                          child: _buildStudentCard(student),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  // -------------------------------------------------------------
  // 🟦 بطاقة الطالب (تصميم عصري + Animation)
  // -------------------------------------------------------------
  Widget _buildStudentCard(dynamic student) {
    final name = student.fullName.toString();
    final initial = name.isNotEmpty ? name[0] : "ط";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape:
              const RoundedRectangleBorder(side: BorderSide.none),

          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue.shade50,
            child: Text(
              initial,
              style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),

          title: Text(
            name,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "ID: ${student.id}",
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),

          trailing: _buildSecondaryMenu(student),

          children: [
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _navigateTo("/shared-add-memorization", student),
                    icon: const Icon(Icons.menu_book_rounded, size: 18),
                    label: const Text("تسجيل تسميع"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _navigateTo("/teacher-attendance", student),
                    icon: Icon(Icons.check_circle_outline_rounded,
                        size: 18, color: Colors.blue.shade700),
                    label: Text("تسجيل حضور",
                        style: TextStyle(color: Colors.blue.shade800)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 🟣 قائمة الخيارات الثانوية
  // -------------------------------------------------------------
  Widget _buildSecondaryMenu(dynamic student) {
    print(student.runtimeType);
print(student.qrCode);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.black54),
      onSelected: (value) {
        if (value == "test") _navigateTo("/teacher-add-test", student);
        if (value == "qr") {
  Navigator.pushNamed(
    context,
    "/shared-student-qr",
    arguments: student, // 👈 PersonModel مباشرة
  );
}

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

  // -------------------------------------------------------------
  // 🟡 شاشة فارغة
  // -------------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "لا يوجد طلاب مضافين في هذه الحلقة حالياً.",
            style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(
                context, "/teacher-add-student",
                arguments: {"halqa": widget.halqa}),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text("أضف طالباً الآن"),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 🟢 الملاحة
  // -------------------------------------------------------------
  void _navigateTo(String route, dynamic student) {
    Navigator.pushNamed(
      context,
      route,
      arguments: {
        "student": student,
        "halqa": widget.halqa,
      },
    );
  }
}
