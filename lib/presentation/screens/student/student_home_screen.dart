import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_providers.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<StudentProvider>().loadAll();
  });
}


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("الصفحة الرئيسية للطالب"),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.profile == null
              ? const Center(child: Text("لا توجد بيانات"))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      "مرحبًا، ${provider.profile!.fullName}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _item(context, "الحضور", "/student-attendance"),
                    _item(context, "الاختبارات", "/student-tests"),
                    _item(context, "الإشعارات", "/student-notifications"),
                    _item(context, "التقدم", "/student-progress"),
                  ],
                ),
    );
  }

  Widget _item(BuildContext context, String title, String route) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
