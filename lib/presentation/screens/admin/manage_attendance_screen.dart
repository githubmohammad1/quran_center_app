import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/admin_providers.dart';

import '../../../data/models/halqa_model.dart';
import 'package:intl/intl.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  HalqaModel? _selectedHalqa;
  DateTime _selectedDate = DateTime.now();

  final Map<int, String> _attendanceMap = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().refreshHalqas();
    });
  }

  Future<void> _saveAllAttendance(BuildContext context) async {
    if (_selectedHalqa == null || _attendanceMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لم تقم بتحديد حلقة أو حالة أي طالب!")),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final adminProv = context.read<AdminProvider>();
    final students = _selectedHalqa!.students;
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    for (var student in students) {
      if (!_attendanceMap.containsKey(student.id)) {
        messenger.showSnackBar(
          SnackBar(
            content: Text("يرجى تحديد حالة الطالب: ${student.fullName}"),
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final entries = _attendanceMap.entries
          .map(
            (entry) => {
              "student": entry.key,
              "halqa": _selectedHalqa!.id,
              "status": entry.value,
              "date": dateString,
            },
          )
          .toList();

      final savedCount = await adminProv.recordAttendanceBatch(entries);
      final snackBar = savedCount == entries.length
          ? const SnackBar(
              content: Text("تم حفظ سجل الحضور بنجاح لجميع الطلاب"),
              backgroundColor: Colors.green,
            )
          : SnackBar(
              content: Text(
                "تم حفظ $savedCount من أصل ${entries.length} طالب. تحقق من الاتصال.",
              ),
              backgroundColor: Colors.orange,
            );

      if (mounted) {
        messenger.showSnackBar(snackBar);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("سجل الحضور اليومي")),
      body: Column(
        children: [
          // اختيار الحلقة والتاريخ
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<HalqaModel>(
                  decoration: const InputDecoration(
                    labelText: "اختر الحلقة",
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedHalqa,
                  items: adminProv.halqas.map((halqa) {
                    return DropdownMenuItem(
                      value: halqa,
                      child: Text(halqa.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedHalqa = val;
                      _attendanceMap.clear();
                    });

                    if (val != null) {
                      for (var student in val.students) {
                        _attendanceMap[student.id] = 'present';
                      }
                    }
                  },
                ),

                const SizedBox(height: 12),

                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  leading: const Icon(
                    Icons.calendar_today,
                    color: Colors.orange,
                  ),
                  title: Text(
                    "التاريخ: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}",
                  ),
                  trailing: const Text("تغيير"),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          // قائمة الطلاب
          Expanded(
            child: _selectedHalqa == null
                ? const Center(child: Text("الرجاء اختيار حلقة للبدء"))
                : _selectedHalqa!.students.isEmpty
                ? const Center(child: Text("لا يوجد طلاب في هذه الحلقة"))
                : ListView.separated(
                    itemCount: _selectedHalqa!.students.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, index) {
                      final student = _selectedHalqa!.students[index];
                      final currentStatus =
                          _attendanceMap[student.id] ?? 'present';

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.fullName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildRadio(
                                  student.id,
                                  'present',
                                  "حاضر",
                                  Colors.green,
                                  currentStatus,
                                ),
                                _buildRadio(
                                  student.id,
                                  'absent',
                                  "غائب",
                                  Colors.red,
                                  currentStatus,
                                ),
                                _buildRadio(
                                  student.id,
                                  'late',
                                  "متأخر",
                                  Colors.orange,
                                  currentStatus,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // زر الحفظ
          if (_selectedHalqa != null && _selectedHalqa!.students.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isSaving ? null : () => _saveAllAttendance(context),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "حفظ الحضور للكل",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRadio(
    int studentId,
    String value,
    String label,
    Color color,
    String groupValue,
  ) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          activeColor: color,
          onChanged: (val) {
            setState(() {
              _attendanceMap[studentId] = val!;
            });
          },
        ),
        Text(
          label,
          style: TextStyle(color: groupValue == value ? color : Colors.black87),
        ),
      ],
    );
  }
}
