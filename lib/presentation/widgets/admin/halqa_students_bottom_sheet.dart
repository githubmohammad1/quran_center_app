import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/halqa_model.dart';
import '../../providers/admin_providers.dart';

Future<void> showHalqaStudentsBottomSheet(
  BuildContext context,
  HalqaModel halqa,
) async {
  final provider = Provider.of<AdminProvider>(context, listen: false);
  if (provider.students.isEmpty) {
    await provider.refreshPersons();
  }
  if (!context.mounted) return;

  await provider.fetchStudentsForHalqa(halqa.id);
  if (!context.mounted) return;

  final selectedStudentIds = provider.currentHalqaStudents
      .map((student) => student.id)
      .toSet();
  String studentSearchQuery = "";
  bool studentsRequested = false;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Consumer<AdminProvider>(
            builder: (context, provider, child) {
              if (!studentsRequested &&
                  provider.students.isEmpty &&
                  !provider.isPersonsLoading) {
                studentsRequested = true;
                Future.microtask(() => provider.refreshPersons());
              }

              final filteredStudents = provider.students.where((student) {
                return student.fullName.toLowerCase().contains(
                  studentSearchQuery.toLowerCase(),
                );
              }).toList();

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  left: 16,
                  right: 16,
                  top: 20,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.72,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.school, color: Colors.indigo),
                          Expanded(
                            child: Text(
                              "إدارة طلاب حلقة: ${halqa.name}",
                              style: const TextStyle(
                                fontFamily: "Cairo",
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.indigo,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text(
                            "(${selectedStudentIds.length} طالب)",
                            style: const TextStyle(
                              fontFamily: "Cairo",
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      TextField(
                        onChanged: (value) {
                          setModalState(() => studentSearchQuery = value);
                        },
                        decoration: InputDecoration(
                          hintText: "ابحث عن طالب بالاسم لإضافته أو إزالته...",
                          hintStyle: const TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 12,
                          ),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: provider.isPersonsLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.indigo,
                                ),
                              )
                            : filteredStudents.isEmpty
                            ? Center(
                                child: Text(
                                  "لا يوجد طلاب مطابقين للبحث",
                                  style: TextStyle(
                                    fontFamily: "Cairo",
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredStudents.length,
                                itemBuilder: (context, index) {
                                  final student = filteredStudents[index];
                                  final isSelected = selectedStudentIds
                                      .contains(student.id);

                                  return CheckboxListTile(
                                    activeColor: Colors.indigo,
                                    title: Text(
                                      student.fullName,
                                      style: const TextStyle(
                                        fontFamily: "Cairo",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "رقم الأهل: ${student.parentPhone ?? 'غير مسجل'}",
                                      style: TextStyle(
                                        fontFamily: "Cairo",
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    value: isSelected,
                                    onChanged: provider.isMutationLoading
                                        ? null
                                        : (checked) {
                                            setModalState(() {
                                              if (checked == true) {
                                                selectedStudentIds.add(
                                                  student.id,
                                                );
                                              } else {
                                                selectedStudentIds.remove(
                                                  student.id,
                                                );
                                              }
                                            });
                                          },
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: provider.isMutationLoading
                            ? null
                            : () async {
                                final updatedData = {
                                  "name": halqa.name,
                                  "teacher": halqa.teacher?.id,
                                  "semester": halqa.semester?.id,
                                  "students": selectedStudentIds.toList(),
                                };

                                final navigator = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);

                                final success = await provider.updateHalqa(
                                  halqa.id,
                                  updatedData,
                                );
                                if (!success) return;

                                await provider.refreshHalqas();
                                navigator.pop();
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "تم تحديث قائمة طلاب الحلقة بنجاح.",
                                      style: TextStyle(fontFamily: "Cairo"),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                        child: provider.isMutationLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "حفظ التغييرات",
                                style: TextStyle(
                                  fontFamily: "Cairo",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
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
    },
  );
}
