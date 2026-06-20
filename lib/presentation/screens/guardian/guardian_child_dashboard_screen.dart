import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/guardian_providers.dart';
import 'package:quran_center_app/presentation/widgets/student_dashboard_content.dart';

class GuardianChildDashboardScreen extends StatelessWidget {
  const GuardianChildDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guardianProvider = context.watch<GuardianProvider>();
    final childProfile = guardianProvider.selectedChild;

    return StudentDashboardContent(
      title: "متابعة الابن",
      headerName: childProfile?.fullName ?? "ملف الابن",
      progress: guardianProvider.progress,
      profile: childProfile,
      isLoading: guardianProvider.loading,
      drawer: null, // لا نعرض القائمة الجانبية هنا لسهولة الرجوع للخلف لقائمة الأبناء
      onRefresh: () async {
        if (childProfile != null) {
          await guardianProvider.selectChild(childProfile);
        }
      },
      onNotificationPressed: () => Navigator.pushNamed(context, "/guardian-child-notifications"),
      onAttendancePressed: () => Navigator.pushNamed(context, "/guardian-child-attendance"),
      onTestsPressed: () => Navigator.pushNamed(context, "/guardian-child-tests"),
      onProgressPressed: () => Navigator.pushNamed(context, "/guardian-child-progress"),
      onQrPressed: () => Navigator.pushNamed(context, "/shared-student-qr", arguments: childProfile),
    );
  }
}