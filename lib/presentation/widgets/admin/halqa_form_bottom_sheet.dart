import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/halqa_model.dart';
import '../../../data/models/person_model.dart';
import '../../providers/admin_providers.dart';

Future<void> showHalqaFormBottomSheet(BuildContext context, {HalqaModel? halqa}) async {
  final bool isEditMode = halqa != null;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: halqa?.name ?? '');
  int? selectedTeacherId = halqa?.teacher?.id;
  int? selectedSupervisorId = halqa?.supervisor?.id;
  int? selectedSemesterId = halqa?.semester?.id;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      return Consumer<AdminProvider>(
        builder: (context, provider, child) {
          final canSubmit = provider.teachers.isNotEmpty && provider.supervisors.isNotEmpty && provider.semesters.isNotEmpty;

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isEditMode ? "تحديث بيانات الحلقة القرآنية" : "إنشاء حلقة قرآنية جديدة",
                      style: const TextStyle(
                        fontFamily: "Cairo",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.indigo,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: nameController,
                      enabled: !provider.isMutationLoading,
                      style: const TextStyle(fontFamily: "Cairo", fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: "اسم الحلقة حتماً",
                        labelStyle: TextStyle(fontFamily: "Cairo", fontSize: 13),
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty) ? "هذا الحقل حرج ومطلوب حتماً" : null,
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      value: selectedTeacherId,
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
                      onChanged: (provider.isMutationLoading || provider.teachers.isEmpty) ? null : (value) => selectedTeacherId = value,
                      validator: (value) => value == null ? "يجب تعيين أستاذ مسؤول عن الحلقة" : null,
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      value: selectedSupervisorId,
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
                      onChanged: (provider.isMutationLoading || provider.supervisors.isEmpty) ? null : (value) => selectedSupervisorId = value,
                      validator: (value) => value == null ? "يجب تعيين موجه مشرف على الحلقة" : null,
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      value: selectedSemesterId,
                      decoration: InputDecoration(
                        labelText: provider.semesters.isEmpty ? "جاري تحميل قائمة الفصول..." : "اختيار الفصل الدراسي",
                        labelStyle: const TextStyle(fontFamily: "Cairo", fontSize: 13),
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: const OutlineInputBorder(),
                      ),
                      items: provider.semesters.map((semester) {
                        return DropdownMenuItem<int>(
                          value: semester.id,
                          child: Text(semester.name, style: const TextStyle(fontFamily: "Cairo", fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (provider.isMutationLoading || provider.semesters.isEmpty) ? null : (value) => selectedSemesterId = value,
                      validator: (value) => value == null ? "يجب اختيار فصل دراسي" : null,
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: (!canSubmit || provider.isMutationLoading)
                          ? null
                          : () async {
                              if (formKey.currentState!.validate()) {
                                final Map<String, dynamic> data = {
                                  "name": nameController.text.trim(),
                                  "teacher": selectedTeacherId,
                                  "supervisor": selectedSupervisorId,
                                  "semester": selectedSemesterId,
                                };
                                final bool success = isEditMode
                                    ? await provider.updateHalqa(halqa!.id, data)
                                    : await provider.createHalqa(data);

                                if (context.mounted && success) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isEditMode ? "تم تحديث بيانات الحلقة بنجاح." : "تم إنشاء الحلقة القرآنية بنجاح.",
                                        style: const TextStyle(fontFamily: "Cairo"),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            },
                      child: provider.isMutationLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              isEditMode ? "حفظ التعديلات" : "إنشاء الحلقة",
                              style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                    ),
                    const SizedBox(height: 10),
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
