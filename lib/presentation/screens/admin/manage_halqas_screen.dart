import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/admin_providers.dart'; // [cite: 1]
import 'package:quran_center_app/presentation/screens/shared/app_shared_drawer.dart'; // [cite: 1]
import '../../../data/models/halqa_model.dart'; // [cite: 1]
import '../../../data/models/person_model.dart'; // [cite: 1]

class ManageHalqasScreen extends StatefulWidget {
  const ManageHalqasScreen({super.key}); // [cite: 1]

  @override
  State<ManageHalqasScreen> createState() => _ManageHalqasScreenState(); // [cite: 2]
}

class _ManageHalqasScreenState extends State<ManageHalqasScreen> {
  final TextEditingController _searchController = TextEditingController(); // [cite: 2]
  String _searchQuery = ""; // [cite: 3]

  @override
  void initState() {
    super.initState(); // [cite: 3]
    // 🚀 جدولة الاستدعاء الميداني بعد استقرار شجرة الواجهات
    WidgetsBinding.instance.addPostFrameCallback((_) { // [cite: 4]
      final adminProvider = Provider.of<AdminProvider>(context, listen: false); // [cite: 4]
      adminProvider.refreshHalqas(); // جلب الحلقات  // [cite: 4]
      
      // تأمين الكادر الإداري والتعليمي لخيارات الـ Dropdown استباقياً
      if (adminProvider.teachers.isEmpty || adminProvider.supervisors.isEmpty) { // [cite: 4]
        adminProvider.refreshPersons(silent: true); //  // [cite: 4]
      }
    }); // [cite: 4]
  } // [cite: 5]

  @override
  void dispose() {
    _searchController.dispose(); // [cite: 5]
    super.dispose(); // [cite: 5]
  } // [cite: 6]

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>(); // [cite: 6]

    // 🚀 تصحيح الجودة: فلترة ذكية آمنة من الـ Null ومتوافقة مع كائن الـ PersonModel
    final filteredHalqas = provider.halqas.where((halqa) { // [cite: 7]
      final nameMatch = halqa.name.toLowerCase().contains(_searchQuery.toLowerCase()); // [cite: 7]
      
      // التحقق الآمن من وجود كائن الأستاذ والبحث في اسمه الكامل
      final teacherMatch = halqa.teacher != null 
          ? halqa.teacher!.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) 
          : false;
          
      return nameMatch || teacherMatch; // [cite: 7]
    }).toList(); // [cite: 7]

    return Scaffold( // [cite: 8]
      appBar: AppBar( // [cite: 8]
        title: const Text("إدارة الحلقات القرآنية", style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold)), // [cite: 8]
        backgroundColor: Colors.indigo, // [cite: 8]
        foregroundColor: Colors.white, // [cite: 8]
        centerTitle: true, // [cite: 8]
      ), // [cite: 8]
      drawer: const AppSharedDrawer(), // دمج الـ Drawer المشترك عالي الجودة // [cite: 8]
      floatingActionButton: FloatingActionButton.extended( // [cite: 8]
        onPressed: () => _showHalqaFormBottomSheet(context), // [cite: 8]
        label: const Text("إضافة حلقة جديدة", style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold)), // [cite: 9]
        icon: const Icon(Icons.add), // [cite: 9]
        backgroundColor: Colors.indigo, // [cite: 9]
        foregroundColor: Colors.white, // [cite: 9]
      ), // [cite: 9]
      body: Column( // [cite: 9]
        children: [ // [cite: 9]
          // 🔍 شريط البحث الاحترافي
          Padding( // [cite: 10]
            padding: const EdgeInsets.all(12.0), // [cite: 10]
            child: TextField( // [cite: 10]
              controller: _searchController, // [cite: 10]
              onChanged: (value) => setState(() => _searchQuery = value), // [cite: 10]
              decoration: InputDecoration( // [cite: 10]
                hintText: "ابحث باسم الحلقة أو اسم الأستاذ...", // [cite: 10]
                hintStyle: const TextStyle(fontFamily: "Cairo", fontSize: 13), // [cite: 11]
                prefixIcon: const Icon(Icons.search, color: Colors.indigo), // [cite: 11]
                suffixIcon: _searchQuery.isNotEmpty // [cite: 11]
                    ? IconButton( // [cite: 12]
                        icon: const Icon(Icons.clear, color: Colors.grey), // [cite: 12]
                        onPressed: () { // [cite: 12]
                          _searchController.clear(); // [cite: 12]
                          setState(() => _searchQuery = ""); // [cite: 13]
                        }, // [cite: 13]
                      ) // [cite: 13]
                    : null, // [cite: 13]
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), // [cite: 13]
                focusedBorder: OutlineInputBorder( // [cite: 14]
                  borderRadius: BorderRadius.circular(12), // [cite: 14]
                  borderSide: const BorderSide(color: Colors.indigo, width: 2), // [cite: 14]
                ), // [cite: 14]
              ), // [cite: 14]
            ), // [cite: 14]
          ), // [cite: 15]

          // 📊 عرض الأخطاء المركزية إن وجدت
          if (provider.error != null) // [cite: 15]
            Container( // [cite: 15]
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // [cite: 15]
              padding: const EdgeInsets.all(10), // [cite: 15]
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)), // [cite: 16]
              child: Row( // [cite: 16]
                children: [ // [cite: 16]
                  const Icon(Icons.error_outline, color: Colors.red), // [cite: 16]
                  const SizedBox(width: 10), // [cite: 16]
                  Expanded( // [cite: 16]
                    child: Text( // [cite: 17]
                      provider.error!, // [cite: 17]
                      style: const TextStyle(color: Colors.red, fontFamily: "Cairo", fontSize: 13), // [cite: 17]
                    ), // [cite: 17]
                  ), // [cite: 18]
                  IconButton( // [cite: 18]
                    icon: const Icon(Icons.close, size: 18, color: Colors.red), // [cite: 18]
                    onPressed: () => provider.clearError(), // [cite: 18]
                  ) // [cite: 18]
                ], // [cite: 19]
              ), // [cite: 19]
            ), // [cite: 19]

          // 🌀 حالة التحميل الرئيسية أو عرض البيانات
          Expanded( // [cite: 19]
            child: provider.isHalqasLoading // [cite: 19]
                ? const Center(child: CircularProgressIndicator(color: Colors.indigo)) // [cite: 20]
                : filteredHalqas.isEmpty // [cite: 20]
                    ? Center( // [cite: 21]
                        child: Column( // [cite: 21]
                          mainAxisAlignment: MainAxisAlignment.center, // [cite: 21]
                          children: [ // [cite: 21]
                            Icon(Icons.layers_clear, size: 64, color: Colors.grey[400]), // [cite: 22]
                            const SizedBox(height: 10), // [cite: 22]
                            Text( // [cite: 22]
                              _searchQuery.isNotEmpty // [cite: 22]
                                  ? "لا توجد نتائج مطابقة لبحثك" // [cite: 23]
                                  : "لا يوجد حلقات مسجلة حالياً في النظام", // [cite: 23]
                              style: TextStyle(fontFamily: "Cairo", color: Colors.grey[600], fontSize: 14), // [cite: 23]
                            ), // [cite: 23]
                          ], // [cite: 24]
                        ), // [cite: 24]
                      ) // [cite: 24]
                    : ListView.builder( // [cite: 24]
                       padding: const EdgeInsets.only(left: 12, right: 12, bottom: 80),
                        itemCount: filteredHalqas.length, // [cite: 25]
                        itemBuilder: (context, index) { // [cite: 25]
                          final halqa = filteredHalqas[index]; // [cite: 25]
                          return _buildHalqaCard(context, halqa); // [cite: 26]
                        }, // [cite: 26]
                      ), // [cite: 26]
          ), // [cite: 26]
        ], // [cite: 26]
      ), // [cite: 26]
    ); // [cite: 26]
  } // 

  // =========================================================================
  // 🎴 كارت عرض الحلقة المستقل والمحمي بصرياً
  // =========================================================================
  Widget _buildHalqaCard(BuildContext context, HalqaModel halqa) { // 
    return Card( // 
      elevation: 2, // 
      margin: const EdgeInsets.symmetric(vertical: 6), // 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // 
      child: ExpansionTile( // 
        leading: const CircleAvatar( // 
          backgroundColor: Colors.indigo, // 
          child: Icon(Icons.group, color: Colors.white), // 
        ), // [cite: 28]
        title: Text( // [cite: 28]
          halqa.name, // [cite: 28]
          style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 15), // [cite: 28]
        ), // [cite: 28]
        // 🚀 تصحيح الجودة: استخراج الاسم من كائن الأستاذ الفعلي واستدعاء الـ Getter لعدد الطلاب
        subtitle: Text( // [cite: 28]
          "المحفّظ: ${halqa.teacher?.fullName ?? 'غير معيّن'} | عدد الطلاب: ${halqa.studentsCount}", // [cite: 27, 28]
          style: TextStyle(fontFamily: "Cairo", fontSize: 12, color: Colors.grey[600]), // [cite: 28]
        ), // [cite: 28]
        children: [ // [cite: 29]
          const Divider(height: 1), // [cite: 29]
          Padding( // [cite: 29]
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // [cite: 29]
            child: Row( // [cite: 29]
              mainAxisAlignment: MainAxisAlignment.end, // [cite: 29]
              children: [ // [cite: 29]
                TextButton.icon( // [cite: 30]
                  icon: const Icon(Icons.edit, color: Colors.orange, size: 18), // [cite: 30]
                  label: const Text("تعديل الحلقة", style: TextStyle(color: Colors.orange, fontFamily: "Cairo", fontSize: 13)), // [cite: 30]
                  onPressed: () => _showHalqaFormBottomSheet(context, halqa: halqa), // [cite: 30]
                ), // [cite: 30]
                const SizedBox(width: 16), // [cite: 31]
                TextButton.icon( // [cite: 31]
                  icon: const Icon(Icons.delete_forever, color: Colors.red, size: 18), // [cite: 31]
                  label: const Text("حذف حلياً", style: TextStyle(color: Colors.red, fontFamily: "Cairo", fontSize: 13)), // [cite: 31]
                  onPressed: () => _confirmDeleteDialog(context, halqa), // [cite: 32]
                ),
                const SizedBox(width: 16),
                // أضف هذا الزر داخل الـ Row في دالة _buildHalqaCard بجانب أزرار التعديل والحذف
TextButton.icon(
  icon: const Icon(Icons.school, color: Colors.blue, size: 18),
  label: const Text("إدارة الطلاب", style: TextStyle(color: Colors.blue, fontFamily: "Cairo", fontSize: 13)),
  onPressed: () => _showManageStudentsBottomSheet(context, halqa),
),
                
                 // [cite: 32]
              ], // [cite: 32]
            ), // [cite: 32]
          ) // [cite: 32]
        ], // [cite: 33]
      ), // [cite: 33]
    ); // [cite: 33]
  } // [cite: 33]
void _showManageStudentsBottomSheet(BuildContext context, HalqaModel halqa) {
  final provider = Provider.of<AdminProvider>(context, listen: false);
  
  // تأمين جلب طلاب المركز بالكامل إن لم يكونوا محملين مسبقاً
  if (provider.students.isEmpty) {
    provider.refreshPersons(silent: true);
  }

  // 🚀 استمثال تقني: تحويل الطلاب الحاليين في الحلقة إلى Set للحصول على تعقيد زمني O(1)
  final Set<int> selectedStudentIds = halqa.students.map((s) => s.id).toSet();
  String studentSearchQuery = "";

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      // 🛠️ فصل منطق الحالة الداخلي عن الواجهة الخارجية لمنع إعادة البناء الكلية أثناء البحث
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          
          // فلترة قائمة طلاب المركز بناءً على نص البحث
          final filteredStudents = provider.students.where((student) {
            return student.fullName.toLowerCase().contains(studentSearchQuery.toLowerCase());
          }).toList();

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 16, right: 16, top: 20,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.65, // تحديد ارتفاع متناسق
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.school, color: Colors.indigo),
                      Text(
                        "إدارة طلاب حلقة: ${halqa.name}",
                        style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo),
                      ),
                      Text(
                        "(${selectedStudentIds.length} طالب)",
                        style: const TextStyle(fontFamily: "Cairo", fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(),
                  
                  // 🔍 شريط بحث داخلي سريع ومكثف للطلاب
                  TextField(
                    onChanged: (val) {
                      setModalState(() => studentSearchQuery = val);
                    },
                    decoration: InputDecoration(
                      hintText: "ابحث عن طالب بالاسم لإضافته أو إزالته...",
                      hintStyle: const TextStyle(fontFamily: "Cairo", fontSize: 12),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🌀 عرض قائمة الطلاب المفلترة مع مؤشرات الاختيار
                  Expanded(
                    child: provider.isPersonsLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
                        : filteredStudents.isEmpty
                            ? Center(
                                child: Text(
                                  "لا يوجد طلاب مطابقين للبحث",
                                  style: TextStyle(fontFamily: "Cairo", color: Colors.grey[500], fontSize: 13),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredStudents.length,
                                itemBuilder: (context, index) {
                                  final student = filteredStudents[index];
                                  final isBelongsToHalqa = selectedStudentIds.contains(student.id);

                                  return CheckboxListTile(
                                    activeColor: Colors.indigo,
                                    title: Text(
                                      student.fullName,
                                      style: const TextStyle(fontFamily: "Cairo", fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      "رقم الأهل: ${student.parentPhone ?? 'غير مسجل'}",
                                      style: TextStyle(fontFamily: "Cairo", fontSize: 11, color: Colors.grey[600]),
                                    ),
                                    value: isBelongsToHalqa,
                                    onChanged: provider.isMutationLoading
                                        ? null
                                        : (bool? checked) {
                                            setModalState(() {
                                              if (checked == true) {
                                                selectedStudentIds.add(student.id);
                                              } else {
                                                selectedStudentIds.remove(student.id);
                                              }
                                            });
                                          },
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: 15),

                  // 🚀 زر الحفظ والمزامنة مع السيرفر
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: provider.isMutationLoading
                        ? null
                        : () async {
                            // تجميع العقد والبيانات لإرسالها بالكامل كـ Payload مطهر
                            final Map<String, dynamic> updatedData = {
                              "name": halqa.name,
                              "teacher": halqa.teacher?.id,
                          
"semester": halqa.semester?.id,     // إرسال الفصل الأكاديمي بشكل منفصل إذا كان مدعوماً في السيرفر
                              "students": selectedStudentIds.toList(), // القائمة الجديدة بالكامل بعد التعديل البشري
                            };

                            // استدعاء دالة التحديث الموحدة والموجودة مسبقاً في الـ Provider
                            final success = await provider.updateHalqa(halqa.id, updatedData);

                            if (context.mounted && success) {
                              Navigator.pop(context); // إغلاق الـ BottomSheet بأمان
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("تم تحديث وتوثيق قائمة طلاب الحلقة بنجاح.", style: TextStyle(fontFamily: "Cairo")),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                    child: provider.isMutationLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text(
                            "حفظ التغييرات ومزامنة كشوف الطلاب",
                            style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
  // =========================================================================
  // 📝 الـ BottomSheet الموحد لعمليتي الإنشاء والتعديل الصارمتين
  // =========================================================================
  void _showHalqaFormBottomSheet(BuildContext context, {HalqaModel? halqa}) { // [cite: 33]
    final isEditMode = halqa != null; // [cite: 33]
    final formKey = GlobalKey<FormState>(); // [cite: 34]
    
    // 🚀 تصحيح الجودة: استخراج معرف الأستاذ من الكائن المدمج بشكل آمن تماماً
    final nameController = TextEditingController(text: isEditMode ? halqa.name : ""); // [cite: 34]
    int? selectedTeacherId = isEditMode ? halqa.teacher?.id : null; // [cite: 35]
    int? selectedSupervisorId; // يُترك للاختيار البشري الجديد لأنه لم يُدرج بعد في موديل الحلقة الفعلي

    showModalBottomSheet( // [cite: 36]
      context: context, // [cite: 36]
      isScrollControlled: true, // [cite: 36]
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), // [cite: 36]
      builder: (context) { // [cite: 36]
        return Consumer<AdminProvider>( // [cite: 36]
          builder: (context, provider, child) { // [cite: 36]
            final canSubmit = provider.teachers.isNotEmpty && provider.supervisors.isNotEmpty; // [cite: 36]

            return Padding( // [cite: 37]
              padding: EdgeInsets.only( // [cite: 37]
                bottom: MediaQuery.of(context).viewInsets.bottom + 20, // [cite: 37]
                left: 16, right: 16, top: 20, // [cite: 37]
              ), // [cite: 37]
              child: Form( // [cite: 37]
                key: formKey, // [cite: 38]
                child: SingleChildScrollView( // [cite: 38]
                  child: Column( // [cite: 38]
                    mainAxisSize: MainAxisSize.min, // [cite: 38]
                    crossAxisAlignment: CrossAxisAlignment.stretch, // [cite: 38]
                    children: [ // [cite: 39]
                      Text( // [cite: 39]
                        isEditMode ? "تحديث بيانات الحلقة القرآنية" : "إنشاء حلقة قرآنية جديدة", // [cite: 40]
                        style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo), // [cite: 40]
                        textAlign: TextAlign.center, // [cite: 40]
                      ), // [cite: 40]
                      const Divider(), // [cite: 41]
                      const SizedBox(height: 10), // [cite: 41]

                      // 1. حقل اسم الحلقة
                      TextFormField( // [cite: 41]
                        controller: nameController, // [cite: 42]
                        enabled: !provider.isMutationLoading, // [cite: 42]
                        style: const TextStyle(fontFamily: "Cairo", fontSize: 14), // [cite: 42]
                        decoration: const InputDecoration( // [cite: 42]
                          labelText: "اسم الحلقة حتماً", // [cite: 43]
                          labelStyle: TextStyle(fontFamily: "Cairo", fontSize: 13), // [cite: 43]
                          prefixIcon: Icon(Icons.badge), // [cite: 43]
                          border: OutlineInputBorder(), // [cite: 44]
                        ), // [cite: 44]
                        validator: (v) => (v == null || v.trim().isEmpty) ? "هذا الحقل حرج ومطلوب حتماً" : null, // [cite: 45]
                      ), // [cite: 45]
                      const SizedBox(height: 15), // [cite: 45]

                      // 2. Dropdown قائمة الأساتذة / المحفظين
                    DropdownButtonFormField<int>(
  // 🚀 تصحيح الجودة: استخدام المعامل الحديث البديل لـ value
  initialValue: selectedTeacherId, 
  decoration: InputDecoration(
    labelText: provider.teachers.isEmpty ? "جاري تحميل قائمة الأساتذة..." : "اختيار الأستاذ المحفّظ",
    labelStyle: const TextStyle(fontFamily: "Cairo", fontSize: 13),
    prefixIcon: const Icon(Icons.person),
    border: const OutlineInputBorder(),
  ),
  items: provider.teachers.map((PersonModel teacher) {
    return DropdownMenuItem<int>(
      value: teacher.id,
      child: Text(teacher.fullName, style: const TextStyle(fontFamily: "Cairo", fontSize: 13)),
    );
  }).toList(),
  // 🚀 تصحيح الجودة: التعطيل عبر إرجاع null للدالة في حال التحميل أو خلو القائمة
  onChanged: (provider.isMutationLoading || provider.teachers.isEmpty)
      ? null
      : (val) => selectedTeacherId = val,
  validator: (v) => v == null ? "يجب تعيين أستاذ مسؤول عن الحلقة" : null,
),// [cite: 51]
                      const SizedBox(height: 15), // [cite: 51]

                      // 3. Dropdown قائمة الموجهين الإداريين
                      DropdownButtonFormField<int>(
  initialValue: selectedSupervisorId, // استخدام الحقل الحديث هنا أيضاً
  decoration: InputDecoration(
    labelText: provider.supervisors.isEmpty ? "جاري تحميل قائمة الموجهين..." : "اختيار الموجه الإداري المشرف",
    labelStyle: const TextStyle(fontFamily: "Cairo", fontSize: 13),
    prefixIcon: const Icon(Icons.assignment_ind),
    border: const OutlineInputBorder(),
  ),
  items: provider.supervisors.map((PersonModel supervisor) {
    return DropdownMenuItem<int>(
      value: supervisor.id,
      child: Text(supervisor.fullName, style: const TextStyle(fontFamily: "Cairo", fontSize: 13)),
    );
  }).toList(),
  // 🚀 تصحيح الجودة: التعطيل الديناميكي الآمن عبر الـ null safety لـ onChanged
  onChanged: (provider.isMutationLoading || provider.supervisors.isEmpty)
      ? null
      : (val) => selectedSupervisorId = val,
  validator: (v) => v == null ? "يجب تعيين موجه مشرف على الحلقة" : null,
),
                      const SizedBox(height: 25), // [cite: 57]

                      // 🚀 زر الحفظ المحمي والمحوكم بمؤشرات الحالة
                      ElevatedButton( // [cite: 58]
                        style: ElevatedButton.styleFrom( // [cite: 58]
                          backgroundColor: Colors.indigo, // [cite: 58]
                          foregroundColor: Colors.white, // [cite: 58]
                          padding: const EdgeInsets.symmetric(vertical: 14), // [cite: 59]
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // [cite: 59]
                        ), // [cite: 59]
                        onPressed: (!canSubmit || provider.isMutationLoading) // [cite: 59]
                            ? null // [cite: 60]
                            : () async { // [cite: 60]
                                if (formKey.currentState!.validate()) { // [cite: 60]
                                 final data = { 
      "name": nameController.text.trim(), 
      "teacher": selectedTeacherId, 
      "supervisor": selectedSupervisorId,
      // 🚀 الحل الحتمي: يجب إرسال معرف الفصل الدراسي النشط هنا
      // افترض أنك تحتفظ بمعرف الفصل النشط في الـ AdminProvider أو تجلبه من السيرفر
      "semester": provider.semesters, // استبدل هذا المتغير بما يطابق منطقك لجلب الـ ID
    };

                                  bool success; // [cite: 64]
                                  if (isEditMode) { // [cite: 64]
                                    success = await provider.updateHalqa(halqa.id, data); // [cite: 64]
                                  } else { // [cite: 65]
                                    success = await provider.createHalqa(data); // [cite: 66]
                                  } // [cite: 66]

                                  if (context.mounted && success) { // [cite: 66]
                                    Navigator.pop(context); // [cite: 67]
                                    ScaffoldMessenger.of(context).showSnackBar( // [cite: 68]
                                      SnackBar( // [cite: 68]
                                        content: Text( // [cite: 69]
                                          isEditMode ? "تم تحديث جودة بيانات الحلقة بنجاح." : "تم إنشاء الحلقة القرآنية وإدراجها بنجاح.", // [cite: 69]
                                          style: const TextStyle(fontFamily: "Cairo"), // [cite: 70]
                                        ), // [cite: 70]
                                        backgroundColor: Colors.green, // [cite: 71]
                                      ), // [cite: 71]
                                    ); // [cite: 71]
                                  } // [cite: 72]
                                } // [cite: 72]
                              }, // [cite: 72]
                        child: provider.isMutationLoading // [cite: 72]
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) // [cite: 74]
                            : Text( // [cite: 74]
                                isEditMode ? "حفظ التعديلات الحتمية" : "تأكيد وبناء الحلقة", // [cite: 74]
                                style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 14), // [cite: 75]
                              ), // [cite: 75]
                      ), // [cite: 58]
                      const SizedBox(height: 10), // [cite: 75]
                    ], // [cite: 76]
                  ), // [cite: 76]
                ), // [cite: 76]
              ), // [cite: 77]
            ); // [cite: 77]
          }, // [cite: 77]
        ); // [cite: 77]
      }, // [cite: 78]
    ); // [cite: 78]
  } // [cite: 78]

  // =========================================================================
  // ⚠️ نافذة الحذف التأكيدية الصارمة لمنع الحذف العشوائي
  // =========================================================================
  void _confirmDeleteDialog(BuildContext context, HalqaModel halqa) { // [cite: 78]
    showDialog( // [cite: 78]
      context: context, // [cite: 78]
      builder: (context) { // [cite: 78]
        return Consumer<AdminProvider>( // [cite: 78]
          builder: (context, provider, child) { // [cite: 78]
            return AlertDialog( // [cite: 78]
              title: const Text("تنبيه جودة حرج!", style: TextStyle(fontFamily: "Cairo", color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.right), // [cite: 79]
              content: Text( // [cite: 79]
                "هل أنت متأكد حتماً من حذف حلقة [${halqa.name}]؟ سيترتب على هذا الإجراء عزل الطلاب المرتبطين بها مؤقتاً.", // [cite: 79]
                style: const TextStyle(fontFamily: "Cairo", fontSize: 13), // [cite: 79]
                textAlign: TextAlign.right, // [cite: 79]
              ), // [cite: 80]
              actions: [ // [cite: 80]
                TextButton( // [cite: 80]
                  onPressed: provider.isMutationLoading ? null : () => Navigator.pop(context), // [cite: 81]
                  child: const Text("إلغاء", style: TextStyle(fontFamily: "Cairo", color: Colors.grey)), // [cite: 81]
                ), // [cite: 81]
                ElevatedButton( // [cite: 81]
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), // [cite: 82]
                  onPressed: provider.isMutationLoading // [cite: 82]
                      ? null // [cite: 82]
                      : () async { // [cite: 82]
                          final success = await provider.deleteHalqa(halqa.id); // [cite: 82]
                          if (context.mounted && success) { // [cite: 83]
                            Navigator.pop(context); // [cite: 83]
                            ScaffoldMessenger.of(context).showSnackBar( // [cite: 83]
                              const SnackBar( // [cite: 84]
                                content: Text("تم حذف الحلقة القرآنية من سجلات النظام بأمان.", style: TextStyle(fontFamily: "Cairo")), // [cite: 84]
                                backgroundColor: Colors.black87, // [cite: 84]
                              ), // [cite: 84]
                            ); // [cite: 84]
                          } // [cite: 86]
                        }, // [cite: 83]
                  child: provider.isMutationLoading // [cite: 86]
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) // [cite: 87]
                      : const Text("نعم، احذف حتماً", style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold)), // [cite: 87]
                ), // [cite: 87]
              ], // [cite: 87]
            ); // [cite: 88]
          }, // [cite: 88]
        ); // [cite: 88]
      }, // [cite: 88]
    ); // [cite: 88]
  } // [cite: 88]
}