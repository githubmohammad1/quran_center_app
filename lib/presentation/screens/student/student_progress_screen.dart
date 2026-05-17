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
    final list = provider.memorization.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "آخر التسميع",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        ...list.map((m) {
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
              leading: Icon(Icons.menu_book, color: Colors.green.shade700),
              title: Text("من ${m.pageFrom} إلى ${m.pageTo}"),
              subtitle: Text("التقدير: ${m.grade}"),
            ),
          );
        }),
      ],
    );
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
