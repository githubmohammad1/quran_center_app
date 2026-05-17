import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/teacher_provider.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  int? selectedHalqaId;
  Map<int, String> attendanceMap = {}; // studentId → status

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("تسجيل الحضور"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _halqaDropdown(provider),
            const SizedBox(height: 20),
            Expanded(child: _studentsList(provider)),
            const SizedBox(height: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _box(),
      child: DropdownButton<int>(
        value: selectedHalqaId,
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text("اختر الحلقة"),
        items: provider.myHalqas.map((h) {
          return DropdownMenuItem(value: h.id, child: Text(h.name));
        }).toList(),
        onChanged: (value) async {
          setState(() => selectedHalqaId = value);
          await provider.loadHalqaStudents(value!);
          attendanceMap.clear();
        },
      ),
    );
  }

  // ---------------------------------------------------------
  // 2) قائمة الطلاب
  // ---------------------------------------------------------
  Widget _studentsList(TeacherProvider provider) {
    if (selectedHalqaId == null) {
      return const Center(child: Text("اختر حلقة لعرض الطلاب"));
    }

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final students = provider.currentHalqaStudents;

    if (students.isEmpty) {
      return const Center(child: Text("لا يوجد طلاب في هذه الحلقة"));
    }

    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final s = students[index];
        final status = attendanceMap[s.id];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: _box(),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  s.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              _statusButton(s.id, "present", "حاضر", Colors.green, status),
              const SizedBox(width: 6),
              _statusButton(s.id, "absent", "غائب", Colors.red, status),
              const SizedBox(width: 6),
              _statusButton(s.id, "late", "متأخر", Colors.orange, status),
            ],
          ),
        );
      },
    );
  }

  Widget _statusButton(
    int studentId,
    String value,
    String label,
    Color color,
    String? selected,
  ) {
    final isSelected = selected == value;

    return InkWell(
      onTap: () {
        setState(() => attendanceMap[studentId] = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 3) زر الحفظ
  // ---------------------------------------------------------
  Widget _saveButton(TeacherProvider provider) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () async {
        if (selectedHalqaId == null) return;

        if (attendanceMap.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("لم يتم اختيار أي حالة حضور")),
          );
          return;
        }

        bool success = true;

        for (var entry in attendanceMap.entries) {
          final halqa = provider.myHalqas.firstWhere(
            (h) => h.id == selectedHalqaId,
          );


          final data = {
            "student": entry.key,
            "halqa": selectedHalqaId,
            "semester": halqa.semester?.id,
            "status": entry.value,
          };

          final result = await provider.saveAttendance(data);
          if (!result) success = false;
        }

        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("تم حفظ الحضور بنجاح")));
        }
      },
      child: const Text(
        "حفظ الحضور",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  // ---------------------------------------------------------
  // صندوق تصميم موحد
  // ---------------------------------------------------------
  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
