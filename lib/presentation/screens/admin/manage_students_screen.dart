import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/data/models/person_model.dart';
import 'package:quran_center_app/presentation/providers/admin_providers.dart';


class ManageStudentsScreen extends StatefulWidget {
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
    // جلب بيانات الأشخاص بصمت في حال لم تكن محملة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      if (provider.students.isEmpty) {
        provider.refreshPersons();
      }
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

    // فلترة الطلاب محلياً (بالاسم أو رقم الهاتف)
    final filteredStudents = provider.students.where((s) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return s.fullName.toLowerCase().contains(q) ||
          (s.user?.phone.contains(q) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("إدارة الطلاب", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () => _showStudentFormDialog(context, provider, null),
        icon: const Icon(Icons.person_add),
        label: const Text("إضافة طالب"),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          
          // شريط التحميل للعمليات (الإضافة، التعديل، الحذف)
          if (provider.isMutationLoading)
            const LinearProgressIndicator(color: Colors.indigo),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.refreshPersons(),
              child: provider.isPersonsLoading && provider.students.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
                  : filteredStudents.isEmpty
                      ? _buildEmptyState()
                      : _buildStudentsList(filteredStudents, provider),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 1. شريط البحث
  // =========================================================================
  // =========================================================================
  // 1. شريط البحث
  // =========================================================================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 8, 
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "ابحث بالاسم أو رقم الهاتف...",
            prefixIcon: const Icon(Icons.search, color: Colors.indigo),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none, // إخفاء حدود الحقل الافتراضية
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
      ),
    );
  }

  // =========================================================================
  // 2. قائمة الطلاب
  // =========================================================================
  Widget _buildStudentsList(List<PersonModel> students, AdminProvider provider) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final student = students[index];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 3))
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: student.isActive ? Colors.indigo.shade50 : Colors.red.shade50,
              child: Icon(Icons.person, color: student.isActive ? Colors.indigo : Colors.red),
            ),
            title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone_android, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(student.user?.phone ?? "لا يوجد رقم حساب", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  if (student.parentPhone != null && student.parentPhone!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.family_restroom, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text("ولي الأمر: ${student.parentPhone}", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ]
                ],
              ),
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  _showStudentFormDialog(context, provider, student);
                } else if (value == 'delete') {
                  _confirmDelete(context, provider, student);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text("تعديل")])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text("حذف")])),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // 3. حالة عدم وجود بيانات
  // =========================================================================
  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Icon(Icons.search_off, size: 80, color: Colors.indigo.shade200),
        const SizedBox(height: 16),
        Center(child: Text("لا توجد نتائج مطابقة", style: TextStyle(fontSize: 18, color: Colors.indigo.shade300))),
      ],
    );
  }

  // =========================================================================
  // 4. نافذة الإضافة والتعديل (Form Dialog)
  // =========================================================================
  void _showStudentFormDialog(BuildContext context, AdminProvider provider, PersonModel? existingStudent) {
    final isEdit = existingStudent != null;
    
    final TextEditingController nameCtrl = TextEditingController(text: existingStudent?.fullName ?? "");
    final TextEditingController phoneCtrl = TextEditingController(text: existingStudent?.user?.phone ?? "");
    final TextEditingController parentPhoneCtrl = TextEditingController(text: existingStudent?.parentPhone ?? "");
    final TextEditingController passwordCtrl = TextEditingController(); // كلمة المرور (إلزامية في الإنشاء، اختيارية في التعديل)
    
    bool isActive = existingStudent?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(isEdit ? "تعديل بيانات الطالب" : "إضافة طالب جديد", style: const TextStyle(color: Colors.indigo)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "الاسم الكامل", prefixIcon: Icon(Icons.person))),
                    const SizedBox(height: 12),
                    TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "رقم هاتف الطالب (تسجيل الدخول)", prefixIcon: Icon(Icons.phone_android))),
                    const SizedBox(height: 12),
                    TextField(controller: passwordCtrl, obscureText: true, decoration: InputDecoration(labelText: isEdit ? "كلمة المرور (اتركه فارغاً لعدم التغيير)" : "كلمة المرور", prefixIcon: const Icon(Icons.lock))),
                    const SizedBox(height: 12),
                    TextField(controller: parentPhoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "رقم هاتف ولي الأمر", prefixIcon: Icon(Icons.family_restroom))),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text("الحساب نشط؟"),
                      activeColor: Colors.indigo,
                      value: isActive,
                      onChanged: (val) => setStateDialog(() => isActive = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء", style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty || (!isEdit && passwordCtrl.text.isEmpty)) {
                      _showSnackBar(context, "الاسم، الهاتف، وكلمة المرور حقول إلزامية", Colors.orange);
                      return;
                    }
                    
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(ctx); 
                    
                    final payload = {
                      "full_name": nameCtrl.text.trim(),
                      "phone": phoneCtrl.text.trim(),
                      "parent_phone": parentPhoneCtrl.text.trim(),
                      "role": "student",
                      "is_active": isActive,
                    };

                    if (passwordCtrl.text.isNotEmpty) {
                      payload["password"] = passwordCtrl.text;
                    }

                    bool success;
                    if (isEdit) {
                      success = await provider.updatePerson(existingStudent.id, payload);
                    } else {
                      success = await provider.createPerson(payload);
                    }

                    if (success) {
                      messenger.showSnackBar(SnackBar(content: Text(isEdit ? "تم التعديل بنجاح" : "تمت الإضافة بنجاح"), backgroundColor: Colors.green));
                    } else {
                      messenger.showSnackBar(SnackBar(content: Text(provider.error ?? "حدث خطأ غير متوقع"), backgroundColor: Colors.red));
                    }
                  },
                  child: Text(isEdit ? "حفظ التعديلات" : "إضافة الطالب"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // =========================================================================
  // 5. نافذة تأكيد الحذف
  // =========================================================================
  void _confirmDelete(BuildContext context, AdminProvider provider, PersonModel student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تأكيد الحذف", style: TextStyle(color: Colors.red)),
        content: Text("هل أنت متأكد من حذف الطالب '${student.fullName}'؟\nسيتم حذف كافة سجلاته."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context); 
              Navigator.pop(ctx);
              
              final success = await provider.deletePerson(student.id);
              if (success) {
                messenger.showSnackBar(const SnackBar(content: Text("تم حذف الطالب بنجاح"), backgroundColor: Colors.green));
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