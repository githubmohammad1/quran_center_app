import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_providers.dart';

class StudentProgressScreen extends StatefulWidget {
  const StudentProgressScreen({super.key});

  @override
  State<StudentProgressScreen> createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends State<StudentProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final progress = provider.progress;

    return Scaffold(
      appBar: AppBar(
        title: const Text("التقدم"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFF1F3F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : progress == null
                ? const Center(child: Text("لا توجد بيانات تقدم"))
                : RefreshIndicator(
                    onRefresh: () async => provider.loadAll(),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _stats(progress),
                        const SizedBox(height: 20),
                        _recentMemorization(provider),
                        const SizedBox(height: 20),
                        _recentTests(provider),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 1) الإحصائيات الأساسية
  // ---------------------------------------------------------
  Widget _stats(progress) {
    return Row(
      children: [
        Expanded(child: _statCard("الصفحات", "${progress.totalPagesMemorized}", Icons.menu_book, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _statCard("الأجزاء", "${progress.totalPartsTested}", Icons.fact_check, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _statCard("النقاط", "${progress.points}", Icons.star, Colors.green)),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 2) آخر عمليات التسميع
  // ---------------------------------------------------------
Widget _recentMemorization(StudentProvider provider) {
  // 1. استخراج معرف الطالب الحالي بأمان من الملف الشخصي المستقر
  final currentStudentId = provider.profile?.id;

  // 2. فلترة ذكية وعزل تام للبيانات: مطابقة معرف الـ student الداخلي للكائن مع حساب المستخدم الحالي
  // هذا يضمن للأستاذ المساعد أن يرى تسميعه الشخصي فقط هنا، ولا تختلط مع تسميع طلاب حلقته
  final myMemorizations = provider.memorization.where((m) {
    if (currentStudentId == null) return true;
    // التطابق الذري: الوصول للمعرف عبر كائن الـ PersonModel المفرز داخلياً
    return m.student?.id == currentStudentId; 
  }).toList();

  // 3. الترتيب التنازلي الحاد (الأحدث أولاً) بناءً على معرف جلسة التسميع
  myMemorizations.sort((a, b) => b.id.compareTo(a.id));

  // اقتطاع آخر 3 جلسات تسميع مسجلة بنجاح
  final list = myMemorizations.take(3).toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "آخر التسميع",
        style: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold,
          fontFamily: "Cairo", // اتساق الخطوط العربية في لوحة المنظومة
        ),
      ),
      const SizedBox(height: 10),

      // 4. هندسة الحالة الفارغة (Empty State) لمنع الجمود البصري للمستخدم
      if (list.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Center(
            child: Text(
              "لا توجد جلسات تسميع مسجلة حالياً.",
              style: TextStyle(color: Colors.grey, fontFamily: "Cairo", fontSize: 14),
            ),
          ),
        )
      else
        // 5. بناء البطاقات البصرية المحدثة بثبات الرسوم واستهلاك معالجات العرض
        ...list.map((m) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade50,
                child: Icon(Icons.menu_book, color: Colors.green.shade700),
              ),
              title: Text(
                "من صفحة ${m.pageFrom} إلى ${m.pageTo}", // مطابقة تامة لـ camelCase في مودلك
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: "Cairo", fontSize: 15),
              ),
              subtitle: Text(
                "التقدير: ${_translateGrade(m.grade)}", // تحسين واجهة القراءة باللغة العربية
                style: TextStyle(
                  color: _getGradeColor(m.grade),
                  fontFamily: "Cairo",
                  fontWeight: FontWeight.w600,
                  fontSize: 13
                ),
              ),
            ),
          );
        }),
    ],
  );
}

/// 🎨 دالة مساعدة لفرز الألوان بحسب روعة التقدير المستحق
Color _getGradeColor(String grade) {
  switch (grade.toLowerCase()) {
    case 'excellent':
    case 'ممتاز':
      return Colors.green.shade700;
    case 'very_good':
    case 'جيد جداً':
      return Colors.blue.shade700;
    case 'good':
    case 'جيد':
      return Colors.orange.shade700;
    default:
      return Colors.grey.shade700;
  }
}

/// 🔠 دالة مساعدة لترجمة التقدير فورياً في الواجهة لراحة العين
String _translateGrade(String grade) {
  switch (grade.toLowerCase()) {
    case 'excellent': return 'ممتاز';
    case 'very_good': return 'جيد جداً';
    case 'good': return 'جيد';
    case 'pass': return 'مقبول';
    case 'fail': return 'راسب';
    default: return grade;
  }
}

  // ---------------------------------------------------------
  // 3) آخر الاختبارات (PART + SURAH)
  // ---------------------------------------------------------
  Widget _recentTests(StudentProvider provider) {
    final list = provider.tests.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "آخر الاختبارات",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        ...list.map((t) {
          final isPart = t.testType == "PART";
          final isSurah = t.testType == "SURAH";

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isPart
                    ? Colors.orange.shade100
                    : Colors.blue.shade100,
                child: Icon(
                  isPart ? Icons.fact_check : Icons.menu_book,
                  color: isPart ? Colors.orange.shade700 : Colors.blue.shade700,
                ),
              ),

              title: Text(
                isPart
                    ? "اختبار جزء رقم ${t.partNumber}"
                    : "اختبار سورة ${t.surah?.name ?? ''}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("التقدير: ${t.grade}"),
                  if (t.notes.isNotEmpty) Text("ملاحظات: ${t.notes}"),
                  Text("التاريخ: ${t.date}", style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
