import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/guardian_providers.dart';

class GuardianChildMemorizationScreen extends StatelessWidget {
  const GuardianChildMemorizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GuardianProvider>();
    // الاعتماد على المصفوفة المخصصة للتسميع الحي والموجودة بالبروفايدر
    final sessionsList = provider.memorizationSessions; 
    final childName = provider.selectedChild?.fullName ?? "الابن";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("سجل تسميع $childName", style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(provider, sessionsList),
    );
  }

  Widget _buildBody(GuardianProvider provider, List<dynamic> sessionsList) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.indigo));
    }

    if (provider.error != null) {
      return Center(
        child: Text(provider.error!, style: const TextStyle(fontFamily: "Cairo", color: Colors.red)),
      );
    }

    if (sessionsList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text("لا توجد جلسات تسميع مسجلة في هذا الفصل.", style: TextStyle(fontFamily: "Cairo", color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessionsList.length,
      itemBuilder: (context, index) {
        final session = sessionsList[index];
        
        // جلب خيارات التقييم وعرضها بما يتوافق مع نمط السيرفر العربي
        final String gradeText = _mapGradeToArabic(session.grade);
        final Color gradeColor = _getGradeColor(session.grade);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_stories, color: Colors.indigo, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "من الصفحة ${session.pageFrom ?? 0} إلى ${session.pageTo ?? 0}",
                        style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "التاريخ: ${session.date ?? '-'}",
                        style: const TextStyle(fontFamily: "Cairo", fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: gradeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    gradeText,
                    style: TextStyle(fontFamily: "Cairo", color: gradeColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // دالة مطابقة التقييمات القادمة من Django لتعريبها بالواجهة بدقة
  String _mapGradeToArabic(String? grade) {
    switch (grade) {
      case 'excellent': return 'ممتاز';
      case 'very_good': return 'جيد جداً';
      case 'good': return 'جيد';
      case 'pass': return 'مقبول';
      case 'redo': return 'إعادة';
      default: return grade ?? 'غير محدد';
    }
  }

  Color _getGradeColor(String? grade) {
    switch (grade) {
      case 'excellent': return Colors.green.shade700;
      case 'very_good': return Colors.blue.shade700;
      case 'good': return Colors.orange.shade700;
      case 'pass': return Colors.amber.shade800;
      case 'redo': return Colors.red.shade700;
      default: return Colors.grey;
    }
  }
}