import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/data/models/academic_year_model.dart';
import 'package:quran_center_app/data/models/semester_model.dart';
import 'package:quran_center_app/presentation/providers/admin_providers.dart';

class ManageAcademicScreen extends StatefulWidget {
  const ManageAcademicScreen({super.key});

  @override
  State<ManageAcademicScreen> createState() => _ManageAcademicScreenState();
}

class _ManageAcademicScreenState extends State<ManageAcademicScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _yearNameController = TextEditingController();
  final TextEditingController _semesterNameController = TextEditingController();
  final TextEditingController _semesterStartController =
      TextEditingController();
  final TextEditingController _semesterEndController = TextEditingController();

  int? _selectedYearId;
  bool _semesterIsActive = false;
  bool _yearIsActive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      if (provider.years.isEmpty || provider.semesters.isEmpty) {
        provider.refreshAcademicData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _yearNameController.dispose();
    _semesterNameController.dispose();
    _semesterStartController.dispose();
    _semesterEndController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initialDate = controller.text.isNotEmpty
        ? DateTime.tryParse(controller.text)
        : DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: Colors.indigo)),
          child: child!,
        );
      },
    );

    if (selected != null) {
      controller.text = _formatDate(selected);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  void _resetAcademicYearForm() {
    _yearNameController.text = "";
    _yearIsActive = false;
  }

  void _resetSemesterForm() {
    _semesterNameController.text = "";
    _semesterStartController.text = "";
    _semesterEndController.text = "";
    _selectedYearId = null;
    _semesterIsActive = false;
  }

  Future<void> _showAcademicYearForm({AcademicYearModel? year}) async {
    final isEditing = year != null;
    final provider = context.read<AdminProvider>();

    if (isEditing) {
      _yearNameController.text = year.name;
      _yearIsActive = year.isActive;
    } else {
      _resetAcademicYearForm();
    }

    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                    isEditing
                        ? "تعديل السنة الأكاديمية"
                        : "إضافة سنة أكاديمية جديدة",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _yearNameController,
                    decoration: const InputDecoration(
                      labelText: "اسم السنة الأكاديمية",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "الرجاء إدخال اسم السنة";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: _yearIsActive,
                    onChanged: (value) {
                      setState(() {
                        _yearIsActive = value;
                      });
                    },
                    title: const Text("السنة نشطة"),
                    activeThumbColor: Colors.indigo,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: provider.isMutationLoading
                              ? null
                              : () async {
                                  final formState = formKey.currentState;
                                  if (formState == null ||
                                      !formState.validate()) {
                                    return;
                                  }
                                  final payload = {
                                    "name": _yearNameController.text.trim(),
                                    "is_active": _yearIsActive,
                                  };

                                  final success = isEditing
                                      ? await provider.updateAcademicYear(
                                          year.id,
                                          payload,
                                        )
                                      : await provider.createAcademicYear(
                                          payload,
                                        );

                                  if (success && context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isEditing
                                              ? "تم تحديث السنة الأكاديمية بنجاح"
                                              : "تم إضافة السنة الأكاديمية بنجاح",
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                        backgroundColor: Colors.indigo.shade700,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: Colors.indigo,
                          ),
                          child: provider.isMutationLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(isEditing ? "حفظ التعديل" : "إنشاء السنة"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSemesterForm({SemesterModel? semester}) async {
    final isEditing = semester != null;
    final provider = context.read<AdminProvider>();

    if (isEditing) {
      _semesterNameController.text = semester.name;
      _semesterStartController.text = semester.startDate;
      _semesterEndController.text = semester.endDate;
      _semesterIsActive = semester.isActive;
      _selectedYearId = semester.year?.id;
    } else {
      _resetSemesterForm();
      if (provider.years.isNotEmpty) {
        _selectedYearId = provider.years.first.id;
      }
    }

    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                    isEditing ? "تعديل الفصل الدراسي" : "إضافة فصل دراسي جديد",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedYearId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "اختر السنة الأكاديمية",
                    ),
                    items: provider.years
                        .map(
                          (year) => DropdownMenuItem(
                            value: year.id,
                            child: Text(year.name),
                          ),
                        )
                        .toList(),
                    onChanged: provider.isMutationLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedYearId = value;
                            });
                          },
                    validator: (value) {
                      if (value == null) {
                        return "الرجاء اختيار السنة الأكاديمية";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _semesterNameController,
                    decoration: const InputDecoration(
                      labelText: "اسم الفصل الدراسي",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "الرجاء إدخال اسم الفصل";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _semesterStartController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "تاريخ بداية الفصل",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    onTap: provider.isMutationLoading
                        ? null
                        : () => _pickDate(_semesterStartController),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "الرجاء اختيار تاريخ البداية";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _semesterEndController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "تاريخ نهاية الفصل",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    onTap: provider.isMutationLoading
                        ? null
                        : () => _pickDate(_semesterEndController),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "الرجاء اختيار تاريخ النهاية";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: _semesterIsActive,
                    onChanged: (value) {
                      setState(() {
                        _semesterIsActive = value;
                      });
                    },
                    title: const Text("الفصل نشط"),
                    activeThumbColor: Colors.indigo,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: provider.isMutationLoading
                              ? null
                              : () async {
                                  final formState = formKey.currentState;
                                  if (formState == null ||
                                      !formState.validate()) {
                                    return;
                                  }
                                  if (_selectedYearId == null) {
                                    return;
                                  }

                                  final payload = {
                                    "year": _selectedYearId,
                                    "name": _semesterNameController.text.trim(),
                                    "start_date": _semesterStartController.text
                                        .trim(),
                                    "end_date": _semesterEndController.text
                                        .trim(),
                                    "is_active": _semesterIsActive,
                                  };

                                  final success = isEditing
                                      ? await provider.updateSemester(
                                          semester.id,
                                          payload,
                                        )
                                      : await provider.createSemester(payload);

                                  if (success && context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isEditing
                                              ? "تم تحديث الفصل الدراسي بنجاح"
                                              : "تم إضافة الفصل الدراسي بنجاح",
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                        backgroundColor: Colors.indigo.shade700,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: Colors.indigo,
                          ),
                          child: provider.isMutationLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(isEditing ? "حفظ التعديل" : "إنشاء الفصل"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text("حذف", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "إدارة السنوات والفصول",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(text: "السنوات"),
            Tab(text: "الفصول"),
          ],
        ),
      ),
      body: Column(
        children: [
          if (provider.error != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: provider.clearError,
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildSummaryCard(
                  title: "إجمالي السنوات",
                  value: provider.years.length.toString(),
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  title: "إجمالي الفصول",
                  value: provider.semesters.length.toString(),
                  color: Colors.green.shade700,
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isAcademicLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.indigo),
                  )
                : RefreshIndicator(
                    onRefresh: () => provider.refreshAcademicData(),
                    color: Colors.indigo,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildYearsTab(provider),
                        _buildSemestersTab(provider),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isMutationLoading
            ? null
            : () {
                if (_tabController.index == 0) {
                  _showAcademicYearForm();
                } else {
                  if (provider.years.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "عذراً، أضف سنة أكاديمية أولاً قبل إنشاء فصل.",
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                  _showSemesterForm();
                }
              },
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? "إضافة سنة" : "إضافة فصل"),
        backgroundColor: provider.isMutationLoading
            ? Colors.grey
            : Colors.indigo,
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.95), color.withOpacity(0.7)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearsTab(AdminProvider provider) {
    if (provider.years.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 80),
          Center(
            child: Text(
              "لم يتم إضافة أي سنة أكاديمية بعد.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      );
    }

    final sortedYears = List<AcademicYearModel>.from(provider.years)
      ..sort((a, b) => b.isActive.toString().compareTo(a.isActive.toString()));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sortedYears.length,
      itemBuilder: (context, index) {
        final year = sortedYears[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            title: Text(
              year.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              year.isActive ? "حاليًا مفعلة" : "غير مفعلة",
              style: TextStyle(
                color: year.isActive ? Colors.green : Colors.grey.shade600,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.amber),
                  onPressed: provider.isMutationLoading
                      ? null
                      : () => _showAcademicYearForm(year: year),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: provider.isMutationLoading
                      ? null
                      : () => _showDeleteConfirmation(
                          title: "حذف السنة الأكاديمية",
                          message:
                              "هل تريد بالتأكيد حذف السنة الأكاديمية ${year.name}? سيتم حذف الفصول المرتبطة بها إذا تُمكن النظام ذلك.",
                          onConfirm: () async {
                            final success = await provider.deleteAcademicYear(
                              year.id,
                            );
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "تم حذف السنة الأكاديمية ${year.name}.",
                                    style: const TextStyle(fontFamily: 'Cairo'),
                                  ),
                                  backgroundColor: Colors.red.shade700,
                                ),
                              );
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSemestersTab(AdminProvider provider) {
    if (provider.semesters.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 80),
          Center(
            child: Text(
              "لم يتم إضافة أي فصل دراسي بعد.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      );
    }

    final sortedSemesters = List<SemesterModel>.from(provider.semesters)
      ..sort((a, b) => b.isActive.toString().compareTo(a.isActive.toString()));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sortedSemesters.length,
      itemBuilder: (context, index) {
        final semester = sortedSemesters[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            title: Text(
              semester.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (semester.year != null)
                  Text(
                    "السنة: ${semester.year?.name}",
                    style: const TextStyle(fontSize: 13),
                  ),
                const SizedBox(height: 4),
                Text(
                  "من ${semester.startDate} إلى ${semester.endDate}",
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  semester.isActive ? "الفصل نشط" : "الفصل غير نشط",
                  style: TextStyle(
                    fontSize: 13,
                    color: semester.isActive
                        ? Colors.green
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.amber),
                  onPressed: provider.isMutationLoading
                      ? null
                      : () => _showSemesterForm(semester: semester),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: provider.isMutationLoading
                      ? null
                      : () => _showDeleteConfirmation(
                          title: "حذف الفصل الدراسي",
                          message:
                              "هل تريد بالتأكيد حذف الفصل الدراسي ${semester.name}?",
                          onConfirm: () async {
                            final success = await provider.deleteSemester(
                              semester.id,
                            );
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "تم حذف الفصل الدراسي ${semester.name}.",
                                    style: const TextStyle(fontFamily: 'Cairo'),
                                  ),
                                  backgroundColor: Colors.red.shade700,
                                ),
                              );
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
