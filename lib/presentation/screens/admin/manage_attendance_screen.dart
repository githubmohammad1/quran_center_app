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
  
  // خريطة لحفظ حالة حضور كل طالب (ID الطالب -> الحالة)
  final Map<int, String> _attendanceMap = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AdminProvider>().halqas.isEmpty) {
        context.read<AdminProvider>().loadAll();
      }
    });
  }

  Future<void> _saveAllAttendance(BuildContext context, AdminProvider provider) async {
    if (_attendanceMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("لم تقم بتحديد حالة أي طالب!")));
      return;
    }

    setState(() => _isSaving = true);
    int successCount = 0;
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // نرسل طلبات الحضور للطلاب الذين تم تغيير حالتهم فقط
    for (var entry in _attendanceMap.entries) {
      final success = await provider.addAttendance({
        "student": entry.key,
        "date": dateStr,
        "status": entry.value,
      });
      if (success) successCount++;
    }

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("تم حفظ حضور $successCount طلاب بنجاح"),
          backgroundColor: successCount > 0 ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("سجل الحضور اليومي")),
      body: Column(
        children: [
          // 1. اختيار الحلقة والتاريخ
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<HalqaModel>(
                  decoration: const InputDecoration(labelText: "اختر الحلقة", border: OutlineInputBorder()),
                  value: _selectedHalqa,
                  items: adminProv.halqas.map((halqa) {
                    return DropdownMenuItem(value: halqa, child: Text(halqa.name));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedHalqa = val;
                      _attendanceMap.clear(); // تصفير الخيارات السابقة
                    });
                    if (val != null) {
                      adminProv.loadHalqaStudents(val.id);
                      // تعيين الكل كـ "حاضر" كوضع افتراضي لتسريع العمل
                      for (var student in adminProv.currentHalqaStudents) {
                        _attendanceMap[student.id] = 'present';
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.grey)),
                  leading: const Icon(Icons.calendar_today, color: Colors.orange),
                  title: Text("التاريخ: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
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

          // 2. قائمة الطلاب مع أزرار الراديو للحالة
          Expanded(
            child: adminProv.loading
                ? const Center(child: CircularProgressIndicator())
                : _selectedHalqa == null
                    ? const Center(child: Text("الرجاء اختيار حلقة للبدء"))
                    : adminProv.currentHalqaStudents.isEmpty
                        ? const Center(child: Text("لا يوجد طلاب في هذه الحلقة"))
                        : ListView.separated(
                            itemCount: adminProv.currentHalqaStudents.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (ctx, index) {
                              final student = adminProv.currentHalqaStudents[index];
                              // إذا لم نضع له قيمة افتراضية نعتبره حاضر
                              final currentStatus = _attendanceMap[student.id] ?? 'present'; 

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(student.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildRadioChoice(student.id, 'present', "حاضر", Colors.green, currentStatus),
                                        _buildRadioChoice(student.id, 'absent', "غائب", Colors.red, currentStatus),
                                        _buildRadioChoice(student.id, 'late', "متأخر", Colors.orange, currentStatus),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
          
          // 3. زر الحفظ
          if (_selectedHalqa != null && adminProv.currentHalqaStudents.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _isSaving ? null : () => _saveAllAttendance(context, adminProv),
                child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("حفظ الحضور للكل", style: TextStyle(fontSize: 18)),
              ),
            ),
        ],
      ),
    );
  }

  // أداة مساعدة لبناء أزرار الاختيار للحالة
  Widget _buildRadioChoice(int studentId, String value, String label, Color color, String groupValue) {
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
        Text(label, style: TextStyle(color: groupValue == value ? color : Colors.black87)),
      ],
    );
  }
}