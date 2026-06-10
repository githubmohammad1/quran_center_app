import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/data/models/surah_model.dart';
import 'package:quran_center_app/presentation/providers/general_provider.dart';
import '../../../data/models/person_model.dart';
import '../../../data/models/quran_test_model.dart';
import '../../../presentation/providers/admin_providers.dart';

class StudentTestHistoryScreen extends StatefulWidget {
  final PersonModel student;
  const StudentTestHistoryScreen({super.key, required this.student});

  @override
  State<StudentTestHistoryScreen> createState() => _StudentTestHistoryScreenState();
}

class _StudentTestHistoryScreenState extends State<StudentTestHistoryScreen> {
  
  // خارطة التقديرات الثابتة لمطابقة خيارات Choices في Django
  final Map<String, String> _gradeChoices = {
    'excellent': 'ممتاز',
    'very_good': 'جيد جداً',
    'good': 'جيد',
    'pass': 'مقبول',
    'fail': 'راسب',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchTestsByStudent(widget.student.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text("سجل اختبارات: ${widget.student.fullName}"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTestDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("إضافة اختبار"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.studentTests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            "لا توجد اختبارات مسجلة لهذا الطالب",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 80),
                      itemCount: provider.studentTests.length,
                      itemBuilder: (context, index) {
                        final QuranTestModel test = provider.studentTests[index];
                        
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(
                              test.testType == "SURAH" 
                                  ? "سورة: ${test.surah?.name ?? 'غير محددة'}"
                                  : "الجزء: ${test.partNumber}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "التقدير: ${_gradeChoices[test.grade] ?? test.grade}  |  التاريخ: ${test.date}",
                              ),
                            ),
                            // 🚀 تحسين: إضافة زري التعديل والحذف معاً بمظهر متناسق
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  onPressed: () => _showEditTestDialog(context, test),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _showDeleteConfirmation(context, test),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          
          if (provider.isMutationLoading)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // ➕ نافذة إضافة اختبار جديد (Add Test Dialog)
  // =========================================================================
  void _showAddTestDialog(BuildContext context) {
    String selectedType = "SURAH";
    int? selectedSurahId; 
    String? selectedGrade; 
    final partController = TextEditingController();
    final notesController = TextEditingController();

    final adminProvider = context.read<AdminProvider>();
    final generalProvider = context.read<GeneralProvider>();

    if (generalProvider.surahs.isEmpty) {
      generalProvider.loadGeneralData();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("تسجيل اختبار قرآني جديد"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: "نوع الاختبار", border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: "SURAH", child: Text("اختبار سورة")),
                        DropdownMenuItem(value: "PART", child: Text("اختبار جزء كامل")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    if (selectedType == "SURAH")
                      DropdownButtonFormField<int>(
                        value: selectedSurahId,
                        decoration: const InputDecoration(
                          labelText: "اختر السورة من المصحف", 
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.menu_book, color: Colors.green),
                        ),
                        hint: const Text("اضغط لاختيار السورة"),
                        items: generalProvider.surahs.map((SurahModel surah) {
                          return DropdownMenuItem<int>(
                            value: surah.number, 
                            child: Text(surah.name), 
                          );
                        }).toList(),
                        onChanged: (id) => setDialogState(() => selectedSurahId = id),
                      )
                    else
                      TextField(
                        controller: partController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "رقم الجزء (1 - 30)",
                          border: OutlineInputBorder(),
                          hintText: "مثال: 30",
                        ),
                      ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedGrade,
                      decoration: const InputDecoration(labelText: "التقدير والنتيجة", border: OutlineInputBorder()),
                      hint: const Text("اختر التقدير الفعلي"),
                      items: _gradeChoices.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key, 
                          child: Text(entry.value), 
                        );
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedGrade = val),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: "ملاحظات الاختبار", border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("إلغاء"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedGrade == null) {
                      _showLocalSnackBar(context, "يرجى تحديد تقدير الطالب أولاً");
                      return;
                    }
                    if (selectedType == "SURAH" && selectedSurahId == null) {
                      _showLocalSnackBar(context, "يرجى اختيار السورة المختبر بها");
                      return;
                    }
                    if (selectedType == "PART" && (int.tryParse(partController.text.trim()) == null || int.parse(partController.text.trim()) < 1 || int.parse(partController.text.trim()) > 30)) {
                      _showLocalSnackBar(context, "يرجى إدخال رقم جزء صحيح بين 1 و 30");
                      return;
                    }
                    if (adminProvider.semesters.isEmpty) {
                      _showLocalSnackBar(context, "لا يوجد فصل دراسي نشط في النظام لإسناد الاختبار إليه");
                      return;
                    }

                    final Map<String, dynamic> testPayload = {
                      "student": widget.student.id, 
                      "semester": adminProvider.semesters.first.id, 
                      "test_type": selectedType, 
                      "grade": selectedGrade, 
                      "notes": notesController.text.trim(), 
                    };

                    if (selectedType == "SURAH") {
                      testPayload["surah"] = selectedSurahId;
                      testPayload["part_number"] = null; 
                    } else {
                      testPayload["part_number"] = int.parse(partController.text.trim());
                      testPayload["surah"] = null; 
                    }

                    final success = await adminProvider.createQuranTest(testPayload, widget.student.id);
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      _showLocalSnackBar(context, "تم تسجيل ومزامنة الاختبار بنجاح", isSuccess: true);
                    } else if (context.mounted) {
                      _showLocalSnackBar(context, adminProvider.error ?? "فشلت عملية الإضافة؛ تحقق من قيود السيرفر");
                    }
                  },
                  child: const Text("تسجيل الاختبار"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // 🔄 ميزة التعديل المضافة: نافذة تعديل بيانات اختبار سابق (Edit Test Dialog)
  // =========================================================================
  void _showEditTestDialog(BuildContext context, QuranTestModel currentTest) {
    String selectedType = currentTest.testType;
    int? selectedSurahId = currentTest.surah?.number; 
    String? selectedGrade = currentTest.grade; 
    final partController = TextEditingController(text: currentTest.partNumber?.toString() ?? "");
    final notesController = TextEditingController(text: currentTest.notes ?? "");

    final adminProvider = context.read<AdminProvider>();
    final generalProvider = context.read<GeneralProvider>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("تعديل بيانات الاختبار المسجل"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. نوع الاختبار (مغلق أو قابل للتعديل حسب رغبتك، يفضل تركه مرن مع تنظيف الحقول المقابلة)
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: "نوع الاختبار", border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: "SURAH", child: Text("اختبار سورة")),
                        DropdownMenuItem(value: "PART", child: Text("اختبار جزء كامل")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // 2. إدارة حقول السورة والجزء ديناميكياً لتجنب كسر قيود الباك إند
                    if (selectedType == "SURAH")
                      DropdownButtonFormField<int>(
                        value: selectedSurahId,
                        decoration: const InputDecoration(
                          labelText: "اختر السورة من المصحف", 
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.menu_book, color: Colors.green),
                        ),
                        hint: const Text("اضغط لاختيار السورة"),
                        items: generalProvider.surahs.map((SurahModel surah) {
                          return DropdownMenuItem<int>(
                            value: surah.number, 
                            child: Text(surah.name), 
                          );
                        }).toList(),
                        onChanged: (id) => setDialogState(() => selectedSurahId = id),
                      )
                    else
                      TextField(
                        controller: partController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "رقم الجزء (1 - 30)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    const SizedBox(height: 12),

                    // 3. تعديل التقدير بشكل صارم
                    DropdownButtonFormField<String>(
                      value: selectedGrade,
                      decoration: const InputDecoration(labelText: "التقدير والنتيجة", border: OutlineInputBorder()),
                      items: _gradeChoices.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key, 
                          child: Text(entry.value), 
                        );
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedGrade = val),
                    ),
                    const SizedBox(height: 12),

                    // 4. الملاحظات
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: "ملاحظات الاختبار", border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("إلغاء"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedGrade == null) {
                      _showLocalSnackBar(context, "يرجى تحديد التقدير");
                      return;
                    }
                    if (selectedType == "SURAH" && selectedSurahId == null) {
                      _showLocalSnackBar(context, "يرجى تحديد السورة");
                      return;
                    }
                    if (selectedType == "PART" && (int.tryParse(partController.text.trim()) == null || int.parse(partController.text.trim()) < 1 || int.parse(partController.text.trim()) > 30)) {
                      _showLocalSnackBar(context, "يرجى إدخال رقم جزء صحيح بين 1 و 30");
                      return;
                    }

                    // تجهيز حمولة التحديث الفعالة لمطابقة الـ PATCH Request في الجانغو
                    final Map<String, dynamic> updatePayload = {
                      "test_type": selectedType,
                      "grade": selectedGrade,
                      "notes": notesController.text.trim(),
                    };

                    if (selectedType == "SURAH") {
                      updatePayload["surah"] = selectedSurahId;
                      updatePayload["part_number"] = null; // ضمان التنظيف لمنع التضارب
                    } else {
                      updatePayload["part_number"] = int.parse(partController.text.trim());
                      updatePayload["surah"] = null; // ضمان التنظيف لمنع التضارب
                    }

                    // تنفيذ التعديل من خلال الـ Provider وإعادة جلب البيانات
                    final success = await adminProvider.updateQuranTest(
                      currentTest.id, 
                      updatePayload, 
                      widget.student.id,
                    );

                    if (success && context.mounted) {
                      Navigator.pop(context);
                      _showLocalSnackBar(context, "تم تحديث بيانات الاختبار بنجاح", isSuccess: true);
                    } else if (context.mounted) {
                      _showLocalSnackBar(context, adminProvider.error ?? "فشل تعديل البيانات");
                    }
                  },
                  child: const Text("حفظ التعديلات"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // ❌ نافذة تأكيد الحذف وبقية التوابع المساعدة
  // =========================================================================
  void _showLocalSnackBar(BuildContext context, String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, QuranTestModel test) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تأكيد الحذف"),
          content: Text(
            test.testType == "SURAH"
                ? "هل أنت متأكد من حذف اختبار سورة (${test.surah?.name}) نهائياً؟"
                : "هل أنت متأكد من حذف اختبار الجزء (${test.partNumber}) نهائياً؟",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () async {
                final adminProvider = context.read<AdminProvider>();
                final success = await adminProvider.deleteQuranTest(test.id, widget.student.id);

                if (success && context.mounted) {
                  Navigator.pop(context);
                  _showLocalSnackBar(context, "تم حذف سجل الاختبار بنجاح", isSuccess: true);
                }
              },
              child: const Text("حذف"),
            ),
          ],
        );
      },
    );
  }
}