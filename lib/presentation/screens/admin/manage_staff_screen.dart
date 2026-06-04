import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/data/models/person_model.dart';
import 'package:quran_center_app/presentation/providers/admin_providers.dart';


class ManageStaffScreen extends StatefulWidget {
  const ManageStaffScreen({super.key});

  @override
  State<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends State<ManageStaffScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // تهيئة التحكم بالتبويب: التبويب 0 للمعلمين، والتبويب 1 للموجهين
    _tabController = TabController(length: 2, vsync: this);
    
    // تحديث البيانات فوراً عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).refreshPersons();
    });

    // إعادة ضبط حالة البحث محلياً عند الانتقال بين التبويبات لتجنب تداخل الفلاتر
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _searchController.clear();
          _searchQuery = "";
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 🛠️ ميكانيكية الفلترة المحلية الذكية المخصصة للكوادر البشرية (Staff)
  List<PersonModel> _filterStaff(List<PersonModel> staffList) {
    if (_searchQuery.isEmpty) return staffList;
    return staffList.where((staff) {
      final name = staff.fullName.toLowerCase();
      final phone = staff.user?.phone ?? "";
      return name.contains(_searchQuery.toLowerCase()) || phone.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context);

    // الرقابة الصارمة وحقن استثناءات الأخطاء القادمة من الباك إند
    if (provider.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!, style: const TextStyle(fontFamily: 'Tajawal')),
            backgroundColor: Colors.red.shade700,
          ),
        );
        provider.clearError(); // تصفير الخطأ فور استهلاكه لمنع تكرار النوافذ
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة الكادر الإداري والتعليمي", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Tajawal'),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14, fontFamily: 'Tajawal'),
          tabs: const [
            Tab(icon: Icon(Icons.school), text: "الأساتذة / المحفّظون"),
            Tab(icon: Icon(Icons.assignment_ind), text: "الموجّهون الميدانيون"),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. شريط البحث الموحد والذكي ذو الاستجابة الفورية
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
                    hintText: "ابحث باسم الموظف أو رقم الهاتف الحسابي...",
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.indigo),
                  ),
                ),
              ),
            ),
          ),

          // 2. محتوى التبويبات المربوط بالـ Provider وقوائمه المعزولة
          Expanded(
            child: provider.isPersonsLoading && provider.teachers.isEmpty && provider.supervisors.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
                : RefreshIndicator(
                    onRefresh: () => provider.refreshPersons(),
                    color: Colors.indigo,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildStaffList(provider, provider.teachers, "teacher"),
                        _buildStaffList(provider, provider.supervisors, "supervisor"),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      // زر العائم الذكي: يحدد دور الموظف تلقائياً بناءً على التبويب النشط حالياً
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isMutationLoading
            ? null
            : () {
                String targetRole = _tabController.index == 0 ? "teacher" : "supervisor";
                _showStaffFormDialog(context, null, targetRole);
              },
        backgroundColor: provider.isMutationLoading ? Colors.grey : Colors.indigo,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: Text(
          _tabController.index == 0 ? "إضافة أستاذ" : "إضافة موجّه",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // =========================================================================
  // مكون بناء قوائم الموظفين (المعلمين أو الموجهين)
  // =========================================================================
  Widget _buildStaffList(AdminProvider provider, List<PersonModel> staffRawList, String roleKey) {
    final filteredList = _filterStaff(staffRawList);

    if (filteredList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          Center(
            child: Text(
              roleKey == "teacher" 
                  ? "لا يوجد أساتذة مسجلين أو يطابقون البحث" 
                  : "لا يوجد موجهين مسجلين أو يطابقون البحث",
              style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, left: 8, right: 8),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final staff = filteredList[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1.5,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: roleKey == "teacher" ? Colors.teal.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              child: Icon(
                roleKey == "teacher" ? Icons.psychology : Icons.verified_user, 
                color: roleKey == "teacher" ? Colors.teal : Colors.orange,
              ),
            ),
            title: Text(
              staff.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text("رقم الهاتف الحسابي: ${staff.user?.phone ?? '—'}"),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // زر التعديل
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.amber),
                  onPressed: provider.isMutationLoading
                      ? null
                      : () => _showStaffFormDialog(context, staff, roleKey),
                ),
                // زر الحذف الأمن التوكيدي
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: provider.isMutationLoading
                      ? null
                      : () => _showDeleteConfirmation(context, provider, staff),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // نافذة النموذج الموحد لإضافة وتعديل بيانات الكوادر (Form Sheet)
  // =========================================================================
  void _showStaffFormDialog(BuildContext context, PersonModel? staff, String defaultRole) {
    final isEditMode = staff != null;
    final formKey = GlobalKey<FormState>();
    
    String fullName = staff?.fullName ?? "";
    String phone = staff?.user?.phone ?? "";
    String selectedRole = isEditMode ? staff.role : defaultRole; // حقل الصلاحية التنفيذية
    String password = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder( // استخدام StatefulBuilder للتحكم بحالة قطاع الراديو داخل الـ BottomSheet بدون إعادة بناء الشاشة كاملة
          builder: (context, setModalState) {
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
                        isEditMode ? "تعديل بيانات الحساب الإداري" : "تسجيل موظف جديد بالنظام",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: fullName,
                        decoration: const InputDecoration(labelText: "الاسم الكامل للموظف", border: OutlineInputBorder()),
                        validator: (v) => v!.trim().isEmpty ? "هذا الحقل مطلوب" : null,
                        onSaved: (v) => fullName = v!.trim(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: "رقم الهاتف (اسم المستخدم للدخول)", border: OutlineInputBorder()),
                        validator: (v) => v!.trim().length < 7 ? "رقم الهاتف غير صالح" : null,
                        onSaved: (v) => phone = v!.trim(),
                      ),
                      const SizedBox(height: 12),
                      
                      // قطاع تحديد الصلاحية والدور في السيرفر لضمان دقة معايير RESTful الـ Role-based Access
                      const Text("الصلاحية والوظيفة الحسابية:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("أستاذ"),
                              value: "teacher",
                              groupValue: selectedRole,
                              onChanged: (val) => setModalState(() => selectedRole = val!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("موجه"),
                              value: "supervisor",
                              groupValue: selectedRole,
                              onChanged: (val) => setModalState(() => selectedRole = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

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
                      
                      // زر الحفظ المربوط بحماية العمليات المتعددة
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
                                        
                                        // تجهيز حزمة الـ Payload المتوافقة بالكامل مع قواعد حوكمة Django
                                        final Map<String, dynamic> payload = {
                                          "full_name": fullName,
                                          "phone": phone,
                                          "role": selectedRole, // الدور المحدد للحساب
                                        };
                                        if (password.isNotEmpty) {
                                          payload["password"] = password;
                                        }

                                        bool success;
                                        if (isEditMode) {
                                          success = await provider.updatePerson(staff.id, payload);
                                        } else {
                                          success = await provider.createPerson(payload);
                                        }

                                        if (success && context.mounted) {
                                          Navigator.pop(context); // إغلاق النموذج بنجاح تام
                                        }
                                      }
                                    },
                              child: provider.isMutationLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(isEditMode ? "حفظ التعديلات الحسابية" : "إتمام تعيين الموظف", 
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
      },
    );
  }

  // =========================================================================
  // حوار الحذف الإداري التأكيدي الصارم
  // =========================================================================
  void _showDeleteConfirmation(BuildContext context, AdminProvider provider, PersonModel staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تحذير أمني: حذف موظف"),
        content: Text("هل أنت متأكد من سحب صلاحيات وحذف حساب الموظف (${staff.fullName}) نهائياً من قاعدة البيانات؟ سيتسبب هذا في إلغاء ارتباطه بأي حلقات تابعة له."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء الإجراء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              bool success = await provider.deletePerson(staff.id);
              if (success && context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("تأكيد الحذف النهائي", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}