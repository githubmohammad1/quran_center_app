import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/admin_providers.dart';

import '../../providers/general_provider.dart';
import '../../../data/models/halqa_model.dart';
import '../../../data/models/person_model.dart';
import 'package:intl/intl.dart';

class AdminTestsScreen extends StatefulWidget {
  const AdminTestsScreen({super.key});

  @override
  State<AdminTestsScreen> createState() => _AdminTestsScreenState();
}

class _AdminTestsScreenState extends State<AdminTestsScreen> {
  HalqaModel? _selectedHalqa;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AdminProvider>().halqas.isEmpty) {
        context.read<AdminProvider>().loadAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("تسجيل الاختبارات")),
      body: Column(
        children: [
          // 1. اختيار الحلقة
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<HalqaModel>(
              decoration: const InputDecoration(labelText: "اختر الحلقة", border: OutlineInputBorder()),
              value: _selectedHalqa,
              items: adminProv.halqas.map((halqa) {
                return DropdownMenuItem(value: halqa, child: Text(halqa.name));
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedHalqa = val);
                if (val != null) {
                  adminProv.loadHalqaStudents(val.id);
                }
              },
            ),
          ),
          
          const Divider(),

          // 2. قائمة طلاب الحلقة
          Expanded(
            child: adminProv.loading
                ? const Center(child: CircularProgressIndicator())
                : _selectedHalqa == null
                    ? const Center(child: Text("الرجاء اختيار حلقة"))
                    : adminProv.currentHalqaStudents.isEmpty
                        ? const Center(child: Text("لا يوجد طلاب في هذه الحلقة"))
                        : ListView.builder(
                            itemCount: adminProv.currentHalqaStudents.length,
                            itemBuilder: (ctx, index) {
                              final student = adminProv.currentHalqaStudents[index];
                              return ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Text(student.fullName),
                                trailing: ElevatedButton(
                                  onPressed: () => _showAddTestDialog(context, student, _selectedHalqa!.semester!.id),
                                  child: const Text("إضافة اختبار"),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  void _showAddTestDialog(BuildContext context, PersonModel student, int semesterId) {
    String testType = 'PART';
    String grade = 'excellent';
    String notes = '';
    int? partNumber;
    int? surahNumber;
    
    // جلب السور من GeneralProvider
    final generalProv = context.read<GeneralProvider>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("اختبار لـ ${student.fullName}"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // نوع الاختبار
                    DropdownButtonFormField<String>(
                      value: testType,
                      decoration: const InputDecoration(labelText: "نوع الاختبار"),
                      items: const [
                        DropdownMenuItem(value: 'PART', child: Text("اختبار جزء")),
                        DropdownMenuItem(value: 'SURAH', child: Text("اختبار سورة")),
                      ],
                      onChanged: (val) {
                        setStateDialog(() {
                          testType = val!;
                          partNumber = null;
                          surahNumber = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // إدخال الجزء أو السورة بناءً على النوع
                    if (testType == 'PART')
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "رقم الجزء (1-30)"),
                        onChanged: (v) => partNumber = int.tryParse(v),
                      )
                    else
                      DropdownButtonFormField<int>(
                        value: surahNumber,
                        decoration: const InputDecoration(labelText: "اختر السورة"),
                        items: generalProv.surahs.map((s) {
                          return DropdownMenuItem(value: s.number, child: Text(s.name));
                        }).toList(),
                        onChanged: (val) => setStateDialog(() => surahNumber = val),
                      ),
                    const SizedBox(height: 12),

                    // التقييم
                    DropdownButtonFormField<String>(
                      value: grade,
                      decoration: const InputDecoration(labelText: "التقييم"),
                      items: const [
                        DropdownMenuItem(value: 'excellent', child: Text("ممتاز")),
                        DropdownMenuItem(value: 'very_good', child: Text("جيد جداً")),
                        DropdownMenuItem(value: 'good', child: Text("جيد")),
                        DropdownMenuItem(value: 'pass', child: Text("مقبول")),
                        DropdownMenuItem(value: 'fail', child: Text("راسب")),
                      ],
                      onChanged: (val) => setStateDialog(() => grade = val!),
                    ),
                    const SizedBox(height: 12),

                    // الملاحظات
                    TextFormField(
                      decoration: const InputDecoration(labelText: "ملاحظات (اختياري)"),
                      onChanged: (v) => notes = v,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
                ElevatedButton(
                  onPressed: () async {
                    if (testType == 'PART' && partNumber == null) return;
                    if (testType == 'SURAH' && surahNumber == null) return;

                    final data = {
                      "student": student.id,
                      "semester": semesterId,
                      "test_type": testType,
                      "grade": grade,
                      "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      "notes": notes,
                    };

                    if (testType == 'PART') data["part_number"] = partNumber!;
                    if (testType == 'SURAH') data["surah_id"] = surahNumber!;

                    Navigator.pop(ctx);
                    
                    final success = await context.read<AdminProvider>().addTest(data);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تسجيل الاختبار بنجاح"), backgroundColor: Colors.green));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("حدث خطأ أثناء التسجيل"), backgroundColor: Colors.red));
                    }
                  },
                  child: const Text("حفظ"),
                ),
              ],
            );
          }
        );
      },
    );
  }
}