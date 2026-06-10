import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/data/models/halqa_model.dart';
import 'package:quran_center_app/data/models/person_model.dart';
import 'package:quran_center_app/data/models/semester_model.dart';
import 'package:quran_center_app/presentation/providers/admin_providers.dart';
import 'package:quran_center_app/presentation/providers/teacher_provider.dart';

class MemorizationSessionSheet extends StatefulWidget {
  final Map<String, dynamic> args;

  const MemorizationSessionSheet({Key? key, required this.args}) : super(key: key);

  @override
  State<MemorizationSessionSheet> createState() => _MemorizationSessionSheetState();
}

class _MemorizationSessionSheetState extends State<MemorizationSessionSheet> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedFromPage;
  int? _selectedToPage;
  String _selectedGrade = 'excellent';
  DateTime _selectedDate = DateTime.now();

  late final PersonModel student;
  late final bool _isAdminMode;
  SemesterModel? _selectedSemester;
  bool _isInitialPagesSet = false;
  bool _loadingSemestersLocal = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    student = widget.args['student'] as PersonModel;
    _isAdminMode = widget.args['mode'] == 'admin';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final semesters = await _loadInitialData();
      if (!mounted) return;

      final halqaData = widget.args['halqa'];
      SemesterModel? initialSemester;
      if (semesters.isNotEmpty) {
        if (halqaData is HalqaModel && halqaData.semester != null) {
          final id = halqaData.semester!.id;
          initialSemester = semesters.firstWhere(
            (s) => s.id == id,
            orElse: () => semesters.first,
          );
        } else {
          initialSemester = semesters.firstWhere(
            (s) => s.isActive,
            orElse: () => semesters.first,
          );
        }
      }

      setState(() {
        _selectedSemester = initialSemester;
      });
    });
  }

  Future<List<SemesterModel>> _loadInitialData() async {
    setState(() => _loadingSemestersLocal = true);

    if (_isAdminMode) {
      final provider = context.read<AdminProvider>();
      await provider.refreshAcademicData(silent: true);
      if (mounted) setState(() => _loadingSemestersLocal = false);
      await provider.loadStudentProgress(student.id);
      return provider.semesters;
    }

    final provider = context.read<TeacherProvider>();
    await provider.loadSemesters();
    if (mounted) setState(() => _loadingSemestersLocal = false);
    await provider.loadStudentProgress(student.id);
    return provider.semesters;
  }

  // اختيار الصفحات عبر اللمس
  void _onPageTap(int pageNum) {
    setState(() {
      if (_selectedFromPage == null || (_selectedFromPage != null && _selectedToPage != null)) {
        _selectedFromPage = pageNum;
        _selectedToPage = null;
      } else if (pageNum >= _selectedFromPage!) {
        _selectedToPage = pageNum;
      } else {
        _selectedFromPage = pageNum;
        _selectedToPage = null;
      }
    });
  }

  bool _isPageSelected(int pageNum) {
    if (_selectedFromPage == null) return false;
    if (_selectedToPage == null) return pageNum == _selectedFromPage;
    return pageNum >= _selectedFromPage! && pageNum <= _selectedToPage!;
  }

  bool _isDateWithinSemester(DateTime date, SemesterModel? sem) {
    if (sem == null) return false;
    try {
      final start = DateTime.parse(sem.startDate);
      final end = DateTime.parse(sem.endDate);
      return !(date.isBefore(start) || date.isAfter(end));
    } catch (_) {
      return false;
    }
  }

  Future<void> _submitData() async {
    if (_isAdminMode) {
      context.read<AdminProvider>().clearError();
    } else {
      context.read<TeacherProvider>().clearError();
    }
    setState(() => _localError = null);

    if (_selectedFromPage == null) {
      setState(() => _localError = "اختر صفحة بداية أولاً");
      return;
    }
    if (_selectedSemester == null) {
      setState(() => _localError = "اختر الفصل الدراسي أولاً");
      return;
    }
    if (!_isDateWithinSemester(_selectedDate, _selectedSemester)) {
      setState(() => _localError = "التاريخ يقع خارج نطاق الفصل الدراسي المحدد");
      return;
    }

    final payload = {
      "student": student.id,
      "semester": _selectedSemester!.id, // إرسال ID فقط
      "page_from": _selectedFromPage,
      "page_to": _selectedToPage ?? _selectedFromPage,
      "grade": _selectedGrade,
      "date": _selectedDate.toIso8601String().split('T').first,
    };

    final success = _isAdminMode
        ? await context.read<AdminProvider>().createMemorizationSession(payload)
        : await context.read<TeacherProvider>().addMemorization(payload, student.id);

    if (success && mounted) {
      if (_isAdminMode) {
        await context.read<AdminProvider>().loadStudentProgress(student.id);
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم حفظ جلسة التسميع وتحديث سجل الطالب بنجاح")),
      );
    } else {
      setState(() {
        _localError = _isAdminMode
            ? context.read<AdminProvider>().error ?? "فشل في حفظ جلسة التسميع"
            : context.read<TeacherProvider>().error ?? "فشل في حفظ جلسة التسميع";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherProvider = context.watch<TeacherProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final semesters = _isAdminMode ? adminProvider.semesters : teacherProvider.semesters;
    final progress = _isAdminMode
        ? adminProvider.selectedStudentProgress
        : teacherProvider.studentProgress;
    final isProgressLoading = _isAdminMode
        ? adminProvider.isProgressLoading
        : teacherProvider.isProgressLoading;
    final isSemestersLoading = _isAdminMode
        ? adminProvider.isAcademicLoading
        : teacherProvider.isSemestersLoading;
    final isSubmitting = _isAdminMode
        ? adminProvider.isMutationLoading
        : teacherProvider.isMutationLoading;

    // تعيين تلقائي لصفحة الانطلاق بناءً على تقدم الطالب لمرة واحدة
    if (progress != null && !_isInitialPagesSet && !isProgressLoading) {
      final nextPage = progress.lastPage + 1;
      if (nextPage <= 604) {
        _selectedFromPage ??= nextPage;
        _selectedToPage ??= nextPage;
      }
      _isInitialPagesSet = true;
    }

    final int startGridPage = ((_selectedFromPage ?? 1) - 10).clamp(1, 604);
    final int endGridPage = (startGridPage + 23).clamp(1, 604);

    return Scaffold(
      appBar: AppBar(title: const Text("تسجيل التسميع التفاعلي"), centerTitle: true),
      body: SafeArea(
        child: isProgressLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    // بطاقة معلومات الطالب
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.15)),
                      ),
                      child: Column(
                        children: [
                          Text("الطالب: ${student.fullName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("آخر صفحة مسجلة تاريخياً: ${progress?.lastPage ?? 'لا يوجد'}",
                              style: TextStyle(color: Colors.grey[700], fontSize: 13)),
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

                    // Dropdown لاختيار الفصل الدراسي
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                      child: _loadingSemestersLocal || isSemestersLoading
                          ? const LinearProgressIndicator()
                          : semesters.isEmpty
                              ? const Text("لا توجد فصول دراسية متاحة", style: TextStyle(color: Colors.grey))
                              : DropdownButtonFormField<int>(
                                  value: _selectedSemester?.id ?? semesters.first.id,
                                  decoration: const InputDecoration(labelText: "اختر الفصل الدراسي", border: OutlineInputBorder()),
                                  items: semesters.map((s) {
                                    return DropdownMenuItem<int>(
                                      value: s.id,
                                      child: Text("${s.name} ${s.isActive ? '- نشط' : ''} (${s.startDate} - ${s.endDate})"),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val == null) return;
                                    setState(() {
                                      _selectedSemester = semesters.firstWhere(
                                        (s) => s.id == val,
                                        orElse: () => semesters.first,
                                      );
                                    });
                                  },
                                ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Icon(Icons.touch_app_outlined, size: 16, color: Colors.grey),
                          SizedBox(width: 6),
                          Text("اضغط لتحديد صفحة البداية ثم صفحة النهاية:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),

                    // شبكة الصفحات
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
                          final pageNum = startGridPage + index;
                          final isSel = _isPageSelected(pageNum);
                          final isStart = pageNum == _selectedFromPage;
                          final isEnd = pageNum == _selectedToPage;

                          return InkWell(
                            onTap: () => _onPageTap(pageNum),
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isSel ? Theme.of(context).primaryColor.withOpacity(0.85) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSel ? Theme.of(context).primaryColor : Colors.grey[300]!,
                                  width: (isStart || isEnd) ? 2.5 : 1.0,
                                ),
                                boxShadow: isSel
                                    ? [
                                        BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.25), blurRadius: 4),
                                      ]
                                    : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("ص $pageNum", style: TextStyle(fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.black87, fontSize: 14)),
                                  if (isStart && _selectedToPage != null && _selectedFromPage != _selectedToPage)
                                    const Text("البداية", style: TextStyle(fontSize: 9, color: Colors.white70)),
                                  if (isEnd) const Text("النهاية", style: TextStyle(fontSize: 9, color: Colors.white70)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // لوحة التقييم وزر الحفظ
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -4))]),
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
                          const SizedBox(height: 12),

                          if (_localError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(_localError!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ),

                          ElevatedButton(
                            onPressed: (isProgressLoading || _selectedFromPage == null || _selectedSemester == null || !_isDateWithinSemester(_selectedDate, _selectedSemester) || isSubmitting)
                                ? null
                                : _submitData,
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                            child: isSubmitting
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text("إرسال التسميع واعتماد النقاط"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
