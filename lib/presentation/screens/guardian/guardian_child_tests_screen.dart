import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/guardian_providers.dart';

class GuardianChildTestsScreen extends StatelessWidget {
  const GuardianChildTestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GuardianProvider>();
    final testsList = provider.tests;
    final childName = provider.selectedChild?.fullName ?? "الابن";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("سجل اختبارات $childName", style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(provider, testsList),
    );
  }

  Widget _buildBody(GuardianProvider provider, List<dynamic> testsList) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.indigo));
    }

    if (provider.error != null) {
      return Center(
        child: Text(provider.error!, style: const TextStyle(fontFamily: "Cairo", color: Colors.red)),
      );
    }

    if (testsList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text("لم يقم الابن بإجراء أي اختبارات رسمية بعد.", style: TextStyle(fontFamily: "Cairo", color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: testsList.length,
      itemBuilder: (context, index) {
        final test = testsList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  child: const Icon(Icons.assignment_turned_in, color: Colors.orange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.title ?? "اختبار قرآن كريم",
                        style: const TextStyle(fontFamily: "Cairo", fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "التاريخ: ${test.date ?? '-'}",
                        style: const TextStyle(fontFamily: "Cairo", fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${test.score ?? 0}%",
                      style: const TextStyle(fontFamily: "Cairo", fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    Text(
                      test.grade ?? "",
                      style: TextStyle(fontFamily: "Cairo", fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}