import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/data/models/halqa_model.dart';
import 'package:quran_center_app/data/models/person_model.dart';
import 'package:quran_center_app/presentation/providers/teacher_provider.dart';

class MemorizationSessionSheet extends StatefulWidget {
  final Map<String, dynamic> args;

  const MemorizationSessionSheet({
    Key? key,
    required this.args,
  }) : super(key: key);

  @override
  State<MemorizationSessionSheet> createState() => _MemorizationSessionSheetState();
}

class _MemorizationSessionSheetState extends State<MemorizationSessionSheet> {
  final _formKey = GlobalKey<FormState>();
  
  int? _selectedFromPage;
  int? _selectedToPage;
  String _selectedGrade = 'excellent';
  final DateTime _selectedDate = DateTime.now();

  late final PersonModel student;
  late final int currentSemesterId;
  bool _isInitialPagesSet = false;

  @override
  void initState() {
    super.initState();
    student = widget.args['student'] as PersonModel;

    final halqaData = widget.args['halqa'];
    if (halqaData is HalqaModel && halqaData.semester != null) {
      currentSemesterId = halqaData.semester!.id;
    } else if (halqaData is Map && halqaData['semester'] != null) {
      currentSemesterId = halqaData['semester']['id'] ?? 1;
    } else {
      currentSemesterId = 1;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherProvider>().loadStudentProgress(student.id);
    });
  }

  // دالة ذكية للتحكم باختيار الصفحات عبر اللمس
  void _onPageTap(int pageNum) {
    setState(() {
      if (_selectedFromPage == null || (_selectedFromPage != null && _selectedToPage != null)) {
        // اللمسة الأولى: تحديد صفحة البداية وإعادة تصفير النهاية
        _selectedFromPage = pageNum;
        _selectedToPage = null;
      } else if (pageNum >= _selectedFromPage!) {
        // اللمسة الثانية: تحديد صفحة النهاية بشرط أن تكون أكبر أو تساوي البداية
        _selectedToPage = pageNum;
      } else {
        // قلب الاختيار إذا اختار صفحة تسبق صفحة البداية
        _selectedFromPage = pageNum;
        _selectedToPage = null;
      }
    });
  }

  // فحص إذا كانت الصفحة تقع ضمن النطاق المختار لتلوينها
  bool _isPageSelected(int pageNum) {
    if (_selectedFromPage == null) return false;
    if (_selectedToPage == null) return pageNum == _selectedFromPage;
    return pageNum >= _selectedFromPage! && pageNum <= _selectedToPage!;
  }

  @override
  Widget build(BuildContext context) {
    final teacherProvider = context.watch<TeacherProvider>();

    // تعيين تلقائي ذكي لصفحة الانطلاق بناءً على بيانات السيرفر لمرة واحدة فقط
    if (teacherProvider.studentProgress != null && !_isInitialPagesSet && !teacherProvider.loadingProgress) {
      int nextPage = (teacherProvider.studentProgress!.lastPage ?? 0) + 1;
      if (nextPage <= 604) {
        _selectedFromPage = nextPage;
        _selectedToPage = nextPage; // افتراضياً تسميع صفحة واحدة
      }
      _isInitialPagesSet = true;
    }

    // تحديد نطاق الجزء الحالي للعرض (مثلاً عرض 24 صفحة المحيطة بتقدم الطالب لراحة الواجهة)
    int startGridPage = ((_selectedFromPage ?? 1) - 10).clamp(1, 604);
    int endGridPage = (startGridPage + 23).clamp(1, 604);

    return Scaffold(
      appBar: AppBar(
        title: const Text("تسجيل التسميع التفاعلي"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: teacherProvider.loadingProgress
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    // كارت معلومات الطالب الحالي
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Text("الطالب: ${student.fullName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            "آخر صفحة مسجلة تاريخياً: ${teacherProvider.studentProgress?.lastPage ?? 'لا يوجد'}",
                            style: TextStyle(color: Colors.grey[700], fontSize: 13),
                          ),
                          if (_selectedFromPage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "النطاق المحدد حالياً: من صـ ${_selectedFromPage} إلى صـ ${_selectedToPage ?? _selectedFromPage}",
                                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Icon(Icons.touch_app_outlined, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text("اضغط لتحديد صفحة البداية ثم صفحة النهاية:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),

                    // شبكة اختيار صفحات المصحف الشريف المرئية
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: (endGridPage - startGridPage) + 1,
                        itemBuilder: (context, index) {
                          int pageNum = startGridPage + index;
                          bool isSel = _isPageSelected(pageNum);
                          bool isStart = pageNum == _selectedFromPage;
                          bool isEnd = pageNum == _selectedToPage;

                          return InkWell(
                            onTap: () => _onPageTap(pageNum),
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isSel 
                                    ? Theme.of(context).primaryColor.withOpacity(0.8)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSel ? Theme.of(context).primaryColor : Colors.grey[300]!,
                                  width: (isStart || isEnd) ? 2.5 : 1.0,
                                ),
                                boxShadow: isSel ? [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 4)] : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "ص $pageNum",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSel ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (isStart && _selectedToPage != null && _selectedFromPage != _selectedToPage)
                                    const Text("البداية", style: TextStyle(fontSize: 9, color: Colors.white70)),
                                  if (isEnd)
                                    const Text("النهاية", style: TextStyle(fontSize: 9, color: Colors.white70)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // لوحة التقييم السفلى وزر الحفظ الأتوماتيكي
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedGrade,
                            decoration: const InputDecoration(labelText: "تقدير التسميع اليومي", border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'excellent', child: Text("ممتاز (بدون أخطاء)")),
                              DropdownMenuItem(value: 'very_good', child: Text("جيد جداً (1-2 أخطاء)")),
                              DropdownMenuItem(value: 'good', child: Text("جيد (3-4 أخطاء)")),
                              DropdownMenuItem(value: 'acceptable', child: Text("مقبول (متردد كثيراً)")),
                            ],
                            onChanged: (value) => setState(() => _selectedGrade = value!),
                          ),
                          const SizedBox(height: 16),
                          
                          if (teacherProvider.error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(teacherProvider.error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ),

                          ElevatedButton(
                            onPressed: (teacherProvider.loading || _selectedFromPage == null) ? null : _submitData,
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                            child: teacherProvider.loading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text("إرسال التسميع واعتماد النقاط"),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  void _submitData() async {
    if (_selectedFromPage == null) return;

    final Map<String, dynamic> payload = {
      "student": student.id,
      "semester": currentSemesterId,
      "page_from": _selectedFromPage,
      "page_to": _selectedToPage ?? _selectedFromPage, // إذا لم يختر صفحة نهاية يعتبرها صفحة واحدة
      "grade": _selectedGrade,
      "date": _selectedDate,
    };

    final teacherProvider = context.read<TeacherProvider>();
    teacherProvider.clearError();
    final bool success = await teacherProvider.addMemorization(payload);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚀 تم تحديث سجل الطالب وضخ النقاط في المحفظة بنجاح")),
      );
    }
  }
}