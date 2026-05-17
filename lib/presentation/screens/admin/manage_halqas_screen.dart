import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/admin_providers.dart';
import '../../../data/models/person_model.dart';
import '../../../data/models/semester_model.dart';

class ManageHalqasScreen extends StatefulWidget {
  const ManageHalqasScreen({super.key});

  @override
  State<ManageHalqasScreen> createState() => _ManageHalqasScreenState();
}

class _ManageHalqasScreenState extends State<ManageHalqasScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

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

    final halqas = provider.halqas.where((h) {
      if (_query.isEmpty) return true;
      return h.name.toLowerCase().contains(_query.toLowerCase()) || 
             (h.teacher?.fullName.toLowerCase().contains(_query.toLowerCase()) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("إدارة الحلقات")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "ابحث باسم الحلقة أو الأستاذ...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: provider.loading && halqas.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : halqas.isEmpty
                      ? const Center(child: Text("لا توجد حلقات مطابقة"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: halqas.length,
                          itemBuilder: (ctx, i) {
                            final h = halqas[i];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.group_work, color: Colors.white),
                                ),
                                title: Text(h.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("الأستاذ: ${h.teacher?.fullName ?? 'غير محدد'}"),
                                    Text("الفصل: ${h.semester?.name ?? ''} | طلاب: ${h.students.length}"),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  // للانتقال لاحقاً لشاشة تفاصيل الحلقة
                                },
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "إضافة حلقة جديدة",
        child: const Icon(Icons.add),
        onPressed: () => _showAddHalqaDialog(context, provider),
      ),
    );
  }

  void _showAddHalqaDialog(BuildContext context, AdminProvider provider) {
    String name = "";
    PersonModel? selectedTeacher;
    SemesterModel? selectedSemester;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("إضافة حلقة جديدة"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: "اسم الحلقة"),
                      onChanged: (v) => name = v,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<PersonModel>(
                      decoration: const InputDecoration(labelText: "الأستاذ"),
                      value: selectedTeacher,
                      items: provider.teachers.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t.fullName));
                      }).toList(),
                      onChanged: (v) => setStateDialog(() => selectedTeacher = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<SemesterModel>(
                      decoration: const InputDecoration(labelText: "الفصل الدراسي"),
                      value: selectedSemester,
                      items: provider.semesters.map((s) {
                        return DropdownMenuItem(value: s, child: Text("${s.name} - ${s.year?.name}"));
                      }).toList(),
                      onChanged: (v) => setStateDialog(() => selectedSemester = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
                ElevatedButton(
                  onPressed: () async {
                    if (name.isEmpty || selectedTeacher == null || selectedSemester == null) return;
                    
                    Navigator.pop(ctx);
                    final success = await provider.createHalqa({
                      "name": name,
                      "teacher_id": selectedTeacher!.id,
                      "semester_id": selectedSemester!.id,
                    });

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تمت الإضافة بنجاح"), backgroundColor: Colors.green));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? "خطأ"), backgroundColor: Colors.red));
                    }
                  },
                  child: const Text("حفظ"),
                ),
              ],
            );
          }
        );
      },
    );
  }
}