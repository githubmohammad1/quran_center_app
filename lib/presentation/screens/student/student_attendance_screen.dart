import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_providers.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل كل بيانات الطالب (بما فيها الحضور)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("سجل الحضور"),
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
            : provider.attendance.isEmpty
                ? const Center(child: Text("لا يوجد سجل حضور"))
                : RefreshIndicator(
                    onRefresh: () async => provider.loadAll(),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _summary(provider),
                        const SizedBox(height: 20),
                        _attendanceList(provider),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 1) ملخص الحضور
  // ---------------------------------------------------------
  Widget _summary(StudentProvider provider) {
    final total = provider.attendance.length;
    final present = provider.attendance.where((a) => a.status == "present").length;
    final absent = provider.attendance.where((a) => a.status == "absent").length;
    final late = provider.attendance.where((a) => a.status == "late").length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _summaryItem("إجمالي الأيام", "$total", Colors.blue),
          _summaryItem("حضور", "$present", Colors.green),
          _summaryItem("غياب", "$absent", Colors.red),
          _summaryItem("تأخر", "$late", Colors.orange),
        ],
      ),
    );
  }

  Widget _summaryItem(String title, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(Icons.circle, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 2) قائمة الحضور اليومية
  // ---------------------------------------------------------
  Widget _attendanceList(StudentProvider provider) {
    final list = provider.attendance;

    return Column(
      children: list.map((a) {
        final isPresent = a.status == "present";
        final isAbsent = a.status == "absent";
        final isLate = a.status == "late";

        Color bg;
        Color iconColor;
        IconData icon;

        if (isPresent) {
          bg = Colors.green.shade100;
          iconColor = Colors.green.shade700;
          icon = Icons.check_circle;
        } else if (isAbsent) {
          bg = Colors.red.shade100;
          iconColor = Colors.red.shade700;
          icon = Icons.cancel;
        } else {
          bg = Colors.orange.shade100;
          iconColor = Colors.orange.shade700;
          icon = Icons.access_time_filled;
        }

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
              backgroundColor: bg,
              child: Icon(icon, color: iconColor),
            ),
            title: Text(
              a.date,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              isPresent
                  ? "حاضر"
                  : isAbsent
                      ? "غائب"
                      : "متأخر",
              style: TextStyle(color: iconColor),
            ),
          ),
        );
      }).toList(),
    );
  }
}
