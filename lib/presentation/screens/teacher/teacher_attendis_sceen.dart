import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/teacher_provider.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  int? selectedHalqaId;
  Map<int, String> attendanceMap = {}; // studentId → status
  bool _isSaving = false; // 🚀 حارس الحالة لمنع الضغط المتكرر وإدارة مؤشر التحميل

  @override
  void initState() {
    super.initState();

    // تحميل الحلقات + الطلاب فوراً عند استقرار الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<TeacherProvider>();
      await provider.loadDashboardData();

      if (provider.myHalqas.isNotEmpty) {
        setState(() {
          selectedHalqaId = provider.myHalqas.first.id;
        });
        await provider.loadHalqaStudents(selectedHalqaId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("تسجيل الحضور والغياب", style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _halqaDropdown(provider),
            const SizedBox(height: 16),
            _markAllPresentButton(provider),
            const SizedBox(height: 12),
            Expanded(child: _studentsList(provider)),
            const SizedBox(height: 12),
            _saveButton(provider),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 1) اختيار الحلقة
  // ---------------------------------------------------------
  Widget _halqaDropdown(TeacherProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: _box(),
      child: DropdownButton<int>(
        value: selectedHalqaId,
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text("اختر الحلقة القرآنية", style: TextStyle(fontFamily: "Cairo")),
        items: provider.myHalqas.map((h) {
          return DropdownMenuItem(value: h.id, child: Text(h.name, style: const TextStyle(fontFamily: "Cairo")));
        }).toList(),
        onChanged: _isSaving ? null : (value) async { // تعطيل الاختيار أثناء الحفظ
          setState(() {
            selectedHalqaId = value;
            attendanceMap.clear();
          });
          await provider.loadHalqaStudents(value!);
        },
      ),
    );
  }

  // ---------------------------------------------------------
  // 2) زر تحديد الكل حاضر
  // ---------------------------------------------------------
  Widget _markAllPresentButton(TeacherProvider provider) {
    if (provider.currentHalqaStudents.isEmpty || _isSaving) return const SizedBox();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.done_all, color: Colors.white),
        label: const Text("تحديد كافة الطلاب كـ حضور", style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold)),
        onPressed: () {
          setState(() {
            for (var s in provider.currentHalqaStudents) {
              attendanceMap[s.id] = "present";
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 3) قائمة الطلاب
  // ---------------------------------------------------------
  Widget _studentsList(TeacherProvider provider) {
    if (selectedHalqaId == null) {
      return const Center(child: Text("يرجى اختيار حلقة لعرض الطلاب", style: TextStyle(fontFamily: "Cairo")));
    }

    if (provider.isProgressLoading) { // تم تصحيح مؤشر التحميل ليتوافق مع الـ Provider
      return const Center(child: CircularProgressIndicator());
    }

    final students = provider.currentHalqaStudents;

    if (students.isEmpty) {
      return const Center(child: Text("لا يوجد طلاب مسجلين في هذه الحلقة حالياً", style: TextStyle(fontFamily: "Cairo")));
    }

    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final s = students[index];
        final status = attendanceMap[s.id];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: _box(),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  s.fullName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: "Cairo"),
                ),
              ),
              _statusButton(s.id, "present", "حاضر", Colors.green, status),
              const SizedBox(width: 4),
              _statusButton(s.id, "absent", "غائب", Colors.red, status),
              const SizedBox(width: 4),
              _statusButton(s.id, "late", "متأخر", Colors.orange, status),
            ],
          ),
        );
      },
    );
  }

  Widget _statusButton(int studentId, String value, String label, Color color, String? selected) {
    final isSelected = selected == value;

    return InkWell(
      onTap: _isSaving ? null : () { // منع تغيير الحالة أثناء الحفظ
        setState(() => attendanceMap[studentId] = value);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: "Cairo",
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 4) زر الحفظ المستمثل مع معالجة الأخطاء
  // ---------------------------------------------------------
  Widget _saveButton(TeacherProvider provider) {
    if (provider.currentHalqaStudents.isEmpty) return const SizedBox();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _isSaving ? null : () async {
          if (selectedHalqaId == null) return;

          final students = provider.currentHalqaStudents;

          // 🛡️ التحقق من إدخال البيانات لجميع الطلاب قبل بدء عاصفة الشبكة
          for (var s in students) {
            if (!attendanceMap.containsKey(s.id)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("يرجى تحديد حالة الطالب: ${s.fullName}", style: const TextStyle(fontFamily: "Cairo")),
                  backgroundColor: Colors.orange.shade800,
                ),
              );
              return;
            }
          }

          setState(() => _isSaving = true);
          int successCount = 0;
          final todayDate = DateTime.now().toIso8601String().split("T").first;

          try {
            // تنفيذ منظم ومتسلسل لحماية الـ Workers في PythonAnywhere من الـ Concurrency Crash
            for (var entry in attendanceMap.entries) {
              final data = {
                "student": entry.key,
                "halqa": selectedHalqaId,
                "status": entry.value,
                "date": todayDate,
              };

              final result = await provider.saveAttendance(data);
              if (result) successCount++;
            }

            if (mounted) {
              if (successCount == students.length) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("تم حفظ سجل الحضور والغياب لجميع الطلاب بنجاح 🎉", style: TextStyle(fontFamily: "Cairo")),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("تم حفظ $successCount من أصل ${students.length}. تحقق من الاتصال بالشبكة.", style: const TextStyle(fontFamily: "Cairo")),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          } finally {
            if (mounted) {
              setState(() => _isSaving = false);
            }
          }
        },
        child: _isSaving
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : const Text(
                "اعتماد وحفظ الجدول",
                style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: "Cairo", fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  // صندوق تصميم نظيف مع معالجة حيود الظل الخفيف
  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}