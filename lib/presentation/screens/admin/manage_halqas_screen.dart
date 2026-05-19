import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/data/models/halqa_model.dart';
import 'package:quran_center_app/data/models/person_model.dart';
import 'package:quran_center_app/data/models/semester_model.dart';
import 'package:quran_center_app/presentation/providers/admin_providers.dart';

// تأكد من مسار الاستيراد الصحيح للـ Provider والموديلات

class ManageHalqasScreen extends StatefulWidget {
  const ManageHalqasScreen({super.key});

  @override
  State<ManageHalqasScreen> createState() => _ManageHalqasScreenState();
}

class _ManageHalqasScreenState extends State<ManageHalqasScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void initState() {
    super.initState();
    // التأكد من جلب البيانات الأساسية (المعلمين والفصول) بصمت لكي تعمل قوائم الإضافة بشكل صحيح
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      if (provider.halqas.isEmpty) provider.refreshHalqas();
      if (provider.teachers.isEmpty) provider.refreshPersons(silent: true);
      if (provider.semesters.isEmpty) provider.refreshAcademicData(silent: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    // فلترة الحلقات محلياً بناءً على البحث
    final halqas = provider.halqas.where((h) {
      if (_query.isEmpty) return true;
      return h.name.toLowerCase().contains(_query.toLowerCase()) || 
             (h.teacher?.fullName.toLowerCase().contains(_query.toLowerCase()) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة الحلقات", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "ابحث باسم الحلقة أو الأستاذ...",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                filled: true,
                fillColor: Colors.green.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          
          // شريط تحميل ناعم للعمليات (مثل الإضافة أو الحذف)
          if (provider.isMutationLoading)
            const LinearProgressIndicator(color: Colors.green),

          // قائمة الحلقات
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.refreshHalqas(),
              child: provider.isHalqasLoading && provider.halqas.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : halqas.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: halqas.length,
                          itemBuilder: (ctx, i) {
                            final h = halqas[i];
                            return _buildHalqaCard(h, provider);
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green.shade700,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("حلقة جديدة", style: TextStyle(color: Colors.white)),
        onPressed: () => _showHalqaFormDialog(context, provider, null),
      ),
    );
  }

  // =========================================================================
  // ويدجت الكارت مع خيارات التعديل والحذف
  // =========================================================================
  Widget _buildHalqaCard(HalqaModel h, AdminProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.group_work, color: Colors.green.shade800),
        ),
        title: Text(h.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(child: Text(h.teacher?.fullName ?? 'بدون أستاذ', overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text("${h.semester?.name ?? ''} | طلاب: ${h.studentsCount}"),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'edit') {
              _showHalqaFormDialog(context, provider, h);
            } else if (value == 'delete') {
              _confirmDelete(context, provider, h);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text("تعديل")])),
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text("حذف")])),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // حالة عدم وجود بيانات
  // =========================================================================
  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Icon(Icons.folder_off, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Center(
          child: Text("لا توجد حلقات دراسية مطابقة", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ),
      ],
    );
  }

  // =========================================================================
  // نافذة الإضافة والتعديل (Form Dialog)
  // =========================================================================
  void _showHalqaFormDialog(BuildContext context, AdminProvider provider, HalqaModel? existingHalqa) {
    final isEdit = existingHalqa != null;
    final TextEditingController nameController = TextEditingController(text: existingHalqa?.name ?? "");
    
    // محاولة إيجاد المعلم والفصل الحاليين في حال التعديل
    PersonModel? selectedTeacher;
    if (isEdit && existingHalqa.teacher != null) {
      try {
        selectedTeacher = provider.teachers.firstWhere((t) => t.id == existingHalqa.teacher!.id);
      } catch (_) { selectedTeacher = null; }
    }

    SemesterModel? selectedSemester;
    if (isEdit && existingHalqa.semester != null) {
      try {
        selectedSemester = provider.semesters.firstWhere((s) => s.id == existingHalqa.semester!.id);
      } catch (_) { selectedSemester = null; }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(isEdit ? "تعديل الحلقة" : "إضافة حلقة جديدة", style: const TextStyle(color: Colors.green)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "اسم الحلقة",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<PersonModel>(
                      decoration: const InputDecoration(labelText: "الأستاذ", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                      value: selectedTeacher,
                      items: provider.teachers.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t.fullName));
                      }).toList(),
                      onChanged: (v) => setStateDialog(() => selectedTeacher = v),
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<SemesterModel>(
                      decoration: const InputDecoration(labelText: "الفصل الدراسي", border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_month)),
                      value: selectedSemester,
                      items: provider.semesters.map((s) {
                        return DropdownMenuItem(value: s, child: Text("${s.name} - ${s.year?.name ?? ''}"));
                      }).toList(),
                      onChanged: (v) => setStateDialog(() => selectedSemester = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء", style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty || selectedTeacher == null || selectedSemester == null) {
                      _showSnackBar(context, "يرجى تعبئة جميع الحقول", Colors.orange);
                      return;
                    }
                    
                    // حفظ كائن الـ Messenger قبل إغلاق النافذة (Context Safety)
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(ctx); 
                    
                    // تحضير البيانات لـ Django
                    final payload = {
                      "name": nameController.text.trim(),
                      "teacher": selectedTeacher!.id,
                      "semester": selectedSemester!.id,
                      if (isEdit) "students": existingHalqa.students.map((s) => s.id).toList(),
                    };

                    bool success;
                    if (isEdit) {
                      success = await provider.updateHalqa(existingHalqa.id, payload); // 🛠️ تم التصحيح هنا
                    } else {
                      success = await provider.createHalqa(payload);
                    }

                    if (success) {
                      messenger.showSnackBar(SnackBar(content: Text(isEdit ? "تم التعديل بنجاح" : "تمت الإضافة بنجاح"), backgroundColor: Colors.green));
                    } else {
                      messenger.showSnackBar(SnackBar(content: Text(provider.error ?? "حدث خطأ غير متوقع"), backgroundColor: Colors.red));
                    }
                  },
                  child: Text(isEdit ? "حفظ التعديلات" : "إضافة"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // =========================================================================
  // نافذة تأكيد الحذف
  // =========================================================================
  void _confirmDelete(BuildContext context, AdminProvider provider, HalqaModel h) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد الحذف", style: TextStyle(color: Colors.red)),
        content: Text("هل أنت متأكد من حذف حلقة '${h.name}'؟\n\nتنبيه: لا يمكن التراجع عن هذا الإجراء."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context); // Context Safety
              Navigator.pop(ctx);
              
              final success = await provider.deleteHalqa(h.id);
              if (success) {
                messenger.showSnackBar(const SnackBar(content: Text("تم حذف الحلقة بنجاح"), backgroundColor: Colors.green));
              } else {
                messenger.showSnackBar(SnackBar(content: Text(provider.error ?? "فشل الحذف"), backgroundColor: Colors.red));
              }
            },
            child: const Text("نعم، احذف"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}