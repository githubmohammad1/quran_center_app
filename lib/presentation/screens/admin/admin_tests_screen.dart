import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/admin_providers.dart';
import '../../providers/general_provider.dart';
import '../../../data/models/halqa_model.dart';
import '../../../data/models/person_model.dart';


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
      context.read<AdminProvider>().refreshHalqas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("تسجيل الاختبارات")),
      body: Column(
        children: [
          // اختيار الحلقة
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<HalqaModel>(
              decoration: const InputDecoration(
                labelText: "اختر الحلقة",
                border: OutlineInputBorder(),
              ),
              initialValue: _selectedHalqa,
              items: adminProv.halqas.map((halqa) {
                return DropdownMenuItem(
                  value: halqa,
                  child: Text(halqa.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedHalqa = val);
              },
            ),
          ),

          const Divider(),

          // قائمة الطلاب
          Expanded(
            child: adminProv.isHalqasLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedHalqa == null
                    ? const Center(child: Text("الرجاء اختيار حلقة"))
                    : _buildStudentsList(_selectedHalqa!),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(HalqaModel halqa) {
    if (halqa.students.isEmpty) {
      return const Center(child: Text("لا يوجد طلاب في هذه الحلقة"));
    }

    return ListView.builder(
      itemCount: halqa.students.length,
      itemBuilder: (ctx, index) {
        final student = halqa.students[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(student.fullName),
          trailing: ElevatedButton(
            onPressed: () => _showAddTestDialog(context, student, halqa.semester?.id),
            child: const Text("إضافة اختبار"),
          ),
        );
      },
    );
  }

  void _showAddTestDialog(BuildContext context, PersonModel student, int? semesterId) {
    String testType = 'PART';
    String grade = 'excellent';
    String notes = '';
    int? partNumber;
    int? surahNumber;

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
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: testType,
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

                    if (testType == 'PART')
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "رقم الجزء (1-30)"),
                        onChanged: (v) => partNumber = int.tryParse(v),
                      )
                    else
                      DropdownButtonFormField<int>(
                        initialValue: surahNumber,
                        decoration: const InputDecoration(labelText: "اختر السورة"),
                        items: generalProv.surahs.map((s) {
                          return DropdownMenuItem(value: s.number, child: Text(s.name));
                        }).toList(),
                        onChanged: (val) => setStateDialog(() => surahNumber = val),
                      ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: grade,
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

                    TextFormField(
                      decoration: const InputDecoration(labelText: "ملاحظات (اختياري)"),
                      onChanged: (v) => notes = v,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
            // 
ElevatedButton(
  onPressed: () async {
    // 1. التحقق الدفاعي من المدخلات الأساسية قبل إرهاق الشبكة والسيرفر
    if (testType == 'PART' && partNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال رقم الجزء أولاً"), backgroundColor: Colors.redAccent),
      );
      return;
    }
    if (testType == 'SURAH' && surahNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى اختيار السورة أولاً"), backgroundColor: Colors.redAccent),
      );
      return;
    }
    if (semesterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطأ: لم يتم التعرف على الفصل الدراسي النشط"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    // 2. صياغة الـ Payload مطابقة لـ QuranTestSerializer في دجانغو 
    final Map<String, dynamic> testPayload = {
      "student": student.id, // معرّف الطالب الأصيل 
      "semester": semesterId, // الفصل الدراسي المساق برمجياً 
      "test_type": testType, // 'PART' أو 'SURAH' 
      "part_number": testType == 'PART' ? partNumber : null, // مصفّر لو كانت سورة 
      "surah": testType == 'SURAH' ? surahNumber : null, // مصفّر لو كان جزء 
      "grade": grade, // التقييم المختار [cite: 12]
      "notes": notes.trim(), // الملاحظات النصية المكتوبة [cite: 15]
      // الـ date سيأخذ timezone.now تلقائياً في السيرفر إن لم نرسله 
    };

    // 3. الاستدعاء البرمجي عبر الـ Provider
    final testProvider = context.read<AdminProvider>();
    
    // إغلاق الديالوج أولاً لتأمين الانسيابية البصرية
    Navigator.pop(ctx); // 

    // إرسال الطلب للسيرفر
    final bool isSuccess = await testProvider.createQuranTest(testPayload);

    if (context.mounted) {
      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("📊 تم تسجيل اختبار (${testType == 'PART' ? 'جزء $partNumber' : 'سورة'}) بنجاح وتحديث السجل."),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // عرض الخطأ الراجع من السيرفر إن وجد
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(testProvider.error ?? "فشل حفظ الاختبار، يرجى مراجعة البيانات"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  },
  child: const Text("حفظ"), // [cite: 20]
),
              ],
            );
          },
        );
      },
    );
  }
}
