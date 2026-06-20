import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/student_providers.dart';
import 'package:quran_center_app/presentation/screens/shared/app_shared_drawer.dart';
import 'package:quran_center_app/presentation/widgets/student_dashboard_content.dart';


class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        context.read<StudentProvider>().loadAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final profile = studentProvider.profile;

    return StudentDashboardContent(
      title: "لوحة تحكم الطالب",
      headerName: profile?.fullName ?? "طالبنا العزيز",
      progress: studentProvider.progress,
      profile: profile,
      isLoading: studentProvider.loading,
      drawer: const AppSharedDrawer(),
      onRefresh: () => studentProvider.loadAll(),
      onNotificationPressed: () => Navigator.pushNamed(context, "/student-notifications"),
      onAttendancePressed: () => Navigator.pushNamed(context, "/student-attendance"),
      onTestsPressed: () => Navigator.pushNamed(context, "/student-tests"),
      onProgressPressed: () => Navigator.pushNamed(context, "/student-progress"),
      onQrPressed: () => Navigator.pushNamed(context, "/shared-student-qr", arguments: profile),
    );
  }
}