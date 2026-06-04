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
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // جلب وتحديث قائمة الطلاب فور بناء الشاشة من الـ API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).refreshPersons();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 🛠️ ميكانيكية الفلترة المحلية المحدثة لتتوافق مع هيكلية الـ PersonModel الجديد
  List<PersonModel> _filterStudents(List<PersonModel> allStudents) {
    if (_searchQuery.isEmpty) return allStudents;
    return allStudents.where((student) {
      final name = student.fullName.toLowerCase();
      final studentPhone = student.user?.phone ?? ""; // جلب الهاتف بأمان من الـ UserModel الفرعي
      final parentPhone = student.parentPhone ?? "";

      return name.contains(_searchQuery.toLowerCase()) || 
             studentPhone.contains(_searchQuery) || 
             parentPhone.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context);

    // معالجة وحقن استثناءات الأخطاء القادمة من السيرفر وعرضها فوراً
    if (provider.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!, style: const TextStyle(fontFamily: 'Tajawal')),
            backgroundColor: Colors.red.shade700,
          ),
        );
        provider.clearError(); // تصفير الخطأ برمجياً فور استهلاكه لمنع تكرار العرض
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة شؤون الطلاب", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // 1. شريط البحث الذكي (🛠️ تم تصحيح الخطأ هنا وتحويل Widget إلى child)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "ابحث باسم الطالب، هاتف الطالب أو ولي الأمر...",
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.indigo),
                  ),
                ),
              ),
            ),
          ),

          // 2. عرض البيانات ومعالجة حالات التحميل
          Expanded(
            child: provider.isPersonsLoading && provider.students.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
                : RefreshIndicator(
                    onRefresh: () => provider.refreshPersons(),
                    color: Colors.indigo,
                    child: _buildStudentList(provider),
                  ),
          ),
        ],
      ),
      // زر إضافة طالب جديد المربوط بـ Guard لحماية النظام من الضغط المتعدد العشوائي
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isMutationLoading
            ? null
            : () => _showStudentFormDialog(context, null),
        backgroundColor: provider.isMutationLoading ? Colors.grey : Colors.indigo,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text("إضافة طالب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // =========================================================================
  // مكون بناء قائمة الطلاب وتوزيع البيانات بناء على النماذج المحدثة
  // =========================================================================
  Widget _buildStudentList(AdminProvider provider) {
    final filteredList = _filterStudents(provider.students);

    if (filteredList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 100),
          Center(
            child: Text(
              "لا يوجد طلاب يطابقون خيارات البحث الحالية",
              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, left: 8, right: 8),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final student = filteredList[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1.5,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo.withOpacity(0.1),
              child: const Icon(Icons.person, color: Colors.indigo),
            ),
            title: Text(
              student.fullName, // 🚀 استهلاك الحقل المدمج الجديد
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("هاتف الطالب: ${student.user?.phone ?? '—'}"), // 🚀 استهلاك حقل الهاتف من حساب المستخدم الفرعي
                  if (student.parentPhone != null && student.parentPhone!.isNotEmpty)
                    Text(
                      "هاتف ولي الأمر: ${student.parentPhone}",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // زر تعديل بيانات الطالب
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.amber),
                  onPressed: provider.isMutationLoading
                      ? null
                      : () => _showStudentFormDialog(context, student),
                ),
                // زر حذف الطالب مع قفل تأكيدي حتمي
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: provider.isMutationLoading
                      ? null
                      : () => _showDeleteConfirmation(context, provider, student),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // نافذة النموذج الموحد (إنشاء / تعديل طالب) المتوافقة مع البنية الجديدة
  // =========================================================================
  void _showStudentFormDialog(BuildContext context, PersonModel? student) {
    final isEditMode = student != null;
    final formKey = GlobalKey<FormState>();
    
    // إسناد القيم الابتدائية بناء على بنية الحقول الجديدة للـ PersonModel
    String fullName = student?.fullName ?? "";
    String phone = student?.user?.phone ?? ""; // جلب الهاتف التابع لليوزر بأمان
    String parentPhone = student?.parentPhone ?? "";
    String password = ""; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditMode ? "تعديل بيانات الطالب" : "تسجيل طالب جديد",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  // حقل الاسم الكامل الموحد
                  TextFormField(
                    initialValue: fullName,
                    decoration: const InputDecoration(labelText: "الاسم الكامل للطالب", border: OutlineInputBorder()),
                    validator: (v) => v!.trim().isEmpty ? "هذا الحقل مطلوب" : null,
                    onSaved: (v) => fullName = v!.trim(),
                  ),
                  const SizedBox(height: 12),
                  // حقل رقم هاتف الطالب (الخاص بالحساب والدخول)
                  TextFormField(
                    initialValue: phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: "رقم هاتف الطالب (للحساب)", border: OutlineInputBorder()),
                    validator: (v) => v!.trim().length < 7 ? "رقم الهاتف غير صالح" : null,
                    onSaved: (v) => phone = v!.trim(),
                  ),
                  const SizedBox(height: 12),
                  // حقل هاتف ولي الأمر (الاختياري للتواصل الإداري)
                  TextFormField(
                    initialValue: parentPhone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: "رقم هاتف ولي الأمر (اختياري)", border: OutlineInputBorder()),
                    onSaved: (v) => parentPhone = v!.trim(),
                  ),
                  const SizedBox(height: 12),
                  // حقل كلمة المرور: إجباري في الإنشاء، اختياري في التعديل
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: isEditMode ? "كلمة مرور جديدة (اتركه فارغاً للاحتفاظ بالحالية)" : "كلمة المرور الافتراضية",
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => (!isEditMode && v!.trim().length < 6) ? "يجب ألا تقل عن 6 محارف" : null,
                    onSaved: (v) => password = v!.trim(),
                  ),
                  const SizedBox(height: 20),
                  
                  // أزرار التحكم والارتباط بالـ Provider
                  Consumer<AdminProvider>(
                    builder: (context, provider, _) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                          onPressed: provider.isMutationLoading
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    formKey.currentState!.save();
                                    
                                    // صياغة حزمة البيانات (Payload) المتوافقة هندسياً مع الباك إند المحدث
                                    final Map<String, dynamic> payload = {
                                      "full_name": fullName,
                                      "phone": phone,
                                      "role": "student", // تحديد الدور لضمان الأمان في حماية الصلاحيات
                                    };
                                    
                                    if (parentPhone.isNotEmpty) {
                                      payload["parent_phone"] = parentPhone;
                                    }
                                    if (password.isNotEmpty) {
                                      payload["password"] = password;
                                    }

                                    bool success;
                                    if (isEditMode) {
                                      success = await provider.updatePerson(student.id, payload);
                                    } else {
                                      success = await provider.createPerson(payload);
                                    }

                                    if (success && context.mounted) {
                                      Navigator.pop(context); // إغلاق النموذج عند النجاح الكامل للعملية
                                    }
                                  }
                                },
                          child: provider.isMutationLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(isEditMode ? "حفظ التعديلات" : "إتمام التسجيل", 
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // نافذة الحذف الأمنية والتأكيدية (Dialogue Window)
  // =========================================================================
  void _showDeleteConfirmation(BuildContext context, AdminProvider provider, PersonModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف الإداري"),
        content: Text("هل أنت متأكد تماماً من حذف حساب الطالب (${student.fullName}) بشكل نهائي من السيرفر؟ لا يمكن التراجع عن هذا الإجراء."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              bool success = await provider.deletePerson(student.id);
              if (success && context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("حذف نهائي", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}