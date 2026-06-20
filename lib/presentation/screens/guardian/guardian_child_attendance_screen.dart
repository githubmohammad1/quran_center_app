import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/guardian_providers.dart';

class GuardianChildAttendanceScreen extends StatelessWidget {
  const GuardianChildAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GuardianProvider>();
    final attendanceList = provider.attendance;
    final childName = provider.selectedChild?.fullName ?? "الابن";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("سجل حضور $childName", style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(context, provider, attendanceList),
    );
  }

  Widget _buildBody(BuildContext context, GuardianProvider provider, List<dynamic> attendanceList) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.indigo));
    }

    if (provider.error != null) {
      return Center(
        child: Text(provider.error!, style: const TextStyle(fontFamily: "Cairo", color: Colors.red)),
      );
    }

    if (attendanceList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text("لا توجد سجلات حضور مسجلة لهذا الابن حالياً.", style: TextStyle(fontFamily: "Cairo", color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: attendanceList.length,
      itemBuilder: (context, index) {
        final record = attendanceList[index];
        // تخصيص اللون والحالة بناءً على بيانات الموديل المتاحة
        final bool isPresent = record.isPresent ?? false; 
        final String statusText = isPresent ? "حضور" : "غياب";
        final Color statusColor = isPresent ? Colors.green : Colors.red;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(isPresent ? Icons.check_circle : Icons.cancel, color: statusColor),
            ),
            title: Text(
              "التاريخ: ${record.date ?? '-'}",
              style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.w600),
            ),
            subtitle: record.notes != null && record.notes!.isNotEmpty
                ? Text("ملاحظة: ${record.notes}", style: const TextStyle(fontFamily: "Cairo", fontSize: 13))
                : null,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: TextStyle(fontFamily: "Cairo", color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }
}