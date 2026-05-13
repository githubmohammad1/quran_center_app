import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/data/models/halqa_model.dart';
import 'package:quran_center_app/data/models/person_model.dart';
import 'package:quran_center_app/presentation/providers/admin_providers.dart';


/// Improved Admin screens:
/// - AdminDashboard (menu)
/// - ManageStudentsScreen (uses AdminProvider)
///
/// Save this file as: lib/presentation/screens/admin/manage_students_screen.dart

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("لوحة التحكم")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _item(context, "إدارة الطلاب",  ManageStudentsScreen.routeName),
          _item(context, "إدارة الحلقات",  ManageHalqasScreen.routeName),
          _item(context, "تسجيل الحضور",  AdminAttendanceScreen.routeName),
          _item(context, "تسجيل الاختبارات",  AdminTestsScreen.routeName),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String title, String route) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Manage Students Screen
/// - loads data from AdminProvider
/// - supports pull-to-refresh, search, error handling
/// - responsive layout for web/large screens
/// ------------------------------------------------------------
class ManageStudentsScreen extends StatefulWidget {
  static const routeName = "/admin-students";
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void initState() {
    super.initState();
    // load data once when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<AdminProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة الطلاب"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "تحديث",
            onPressed: provider.loading ? null : _refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "ابحث بالاسم أو الهاتف",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = "");
                                    },
                                  )
                                : null,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (v) => setState(() => _query = v.trim()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: provider.loading ? null : _refresh,
                        icon: const Icon(Icons.download),
                        label: const Text("تحديث"),
                      ),
                    ],
                  ),
                ),

                // status / error
                if (provider.loading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(),
                  ),

                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Material(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      child: ListTile(
                        leading: const Icon(Icons.error, color: Colors.red),
                        title: Text(provider.error!, style: const TextStyle(color: Colors.red)),
                        trailing: TextButton(
                          child: const Text("إعادة المحاولة"),
                          onPressed: provider.loading ? null : _refresh,
                        ),
                      ),
                    ),
                  ),

                // content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: _buildContent(provider),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "إضافة طالب جديد",
        child: const Icon(Icons.person_add),
        onPressed: () {
          // navigate to create student screen (implement separately)
          Navigator.pushNamed(context, "/admin-student-create");
        },
      ),
    );
  }

  Widget _buildContent(AdminProvider provider) {
    final students = provider.students.where((s) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      final name = s.fullName.toLowerCase();
      final phone = s.user?.phone?.toLowerCase() ?? "";
      return name.contains(q) || phone.contains(q);
    }).toList();

    if (provider.loading && students.isEmpty) {
      return const Center(child: Text("جارٍ التحميل..."));
    }

    if (students.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(child: Text(provider.error == null ? "لا يوجد طلاب" : "لا توجد نتائج")),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final student = students[index];
        return _studentCard(context, student);
      },
    );
  }

  Widget _studentCard(BuildContext context, PersonModel student) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 26,
          child: Text(_initials(student.fullName), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text(student.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        subtitle: Text("الهاتف: ${student.user?.phone ?? 'غير متوفر'}"),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _onAction(context, value, student),
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'view', child: Text('عرض')),
            const PopupMenuItem(value: 'attendance', child: Text('سجل الحضور')),
            const PopupMenuItem(value: 'edit', child: Text('تعديل')),
            const PopupMenuItem(value: 'delete', child: Text('حذف')),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, "/admin-student-detail", arguments: student);
        },
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void _onAction(BuildContext context, String action, PersonModel student) {
    switch (action) {
      case 'view':
        Navigator.pushNamed(context, "/admin-student-detail", arguments: student);
        break;
      case 'attendance':
        Navigator.pushNamed(context, "/admin-student-attendance", arguments: student);
        break;
      case 'edit':
        Navigator.pushNamed(context, "/admin-student-edit", arguments: student);
        break;
      case 'delete':
        _confirmDelete(context, student);
        break;
    }
  }

  void _confirmDelete(BuildContext context, PersonModel student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: Text("هل تريد حذف الطالب ${student.fullName}؟ هذا الإجراء لا يمكن التراجع عنه."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // call delete API via AdminProvider (implement delete in provider/repo)
              // context.read<AdminProvider>().deleteStudent(student.id);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تنفيذ الحذف (تجريبي)")));
            },
            child: const Text("حذف"),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Placeholder screens for other admin routes referenced above.
/// Implement these screens in separate files as needed.
/// ------------------------------------------------------------
class ManageHalqasScreen extends StatelessWidget {
  static const routeName = "/admin-halqas";
  const ManageHalqasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final halqas = provider.halqas;

    return Scaffold(
      appBar: AppBar(title: const Text("إدارة الحلقات")),
      body: halqas.isEmpty
          ? const Center(child: Text("لا توجد حلقات"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: halqas.length,
              itemBuilder: (ctx, i) {
                final HalqaModel h = halqas[i];
                return Card(
                  child: ListTile(
                    title: Text(h.name),
                    subtitle: Text("الأستاذ: ${h.teacher?.fullName ?? 'غير محدد'}"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, "/admin-halqa-detail", arguments: h),
                  ),
                );
              },
            ),
    );
  }
}

class AdminAttendanceScreen extends StatelessWidget {
  static const routeName = "/admin-attendance";
  const AdminAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تسجيل الحضور")),
      body: const Center(child: Text("شاشة تسجيل الحضور (قيد التنفيذ)")),
    );
  }
}

class AdminTestsScreen extends StatelessWidget {
  static const routeName = "/admin-tests";
  const AdminTestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تسجيل الاختبارات")),
      body: const Center(child: Text("شاشة تسجيل الاختبارات (قيد التنفيذ)")),
    );
  }
}
