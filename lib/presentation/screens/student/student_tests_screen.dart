import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_providers.dart';

class StudentTestsScreen extends StatefulWidget {
  const StudentTestsScreen({super.key});

  @override
  State<StudentTestsScreen> createState() => _StudentTestsScreenState();
}

class _StudentTestsScreenState extends State<StudentTestsScreen> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("اختبارات الطالب"),
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
            : provider.tests.isEmpty
                ? const Center(child: Text("لا توجد اختبارات"))
                : RefreshIndicator(
                    onRefresh: () async => provider.loadAll(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.tests.length,
                      itemBuilder: (context, index) {
                        final t = provider.tests[index];
                        return _testCard(t);
                      },
                    ),
                  ),
      ),
    );
  }

  // ---------------------------------------------------------
  // بطاقة اختبار
  // ---------------------------------------------------------
  Widget _testCard(test) {
    final isPart = test.testType == "PART";
    final isSurah = test.testType == "SURAH";

    Color color = isPart ? Colors.orange : Colors.blue;
    IconData icon = isPart ? Icons.fact_check : Icons.menu_book;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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

      child: Row(
        children: [
          // أيقونة نوع الاختبار
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 28),
          ),

          const SizedBox(width: 16),

          // النصوص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPart
                      ? "اختبار جزء رقم ${test.partNumber}"
                      : "اختبار سورة ${test.surah?.name ?? ''}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "التقدير: ${test.grade}",
                  style: const TextStyle(color: Colors.black87),
                ),

                if (test.notes.isNotEmpty)
                  Text(
                    "ملاحظات: ${test.notes}",
                    style: const TextStyle(color: Colors.black54),
                  ),

                const SizedBox(height: 6),

                Text(
                  test.date,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
