import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/admin_providers.dart';
import 'package:quran_center_app/presentation/screens/shared/app_shared_drawer.dart';
import '../../../data/models/halqa_model.dart';
import '../../widgets/admin/halqa_card.dart';
import '../../widgets/admin/halqa_form_bottom_sheet.dart';
import '../../widgets/admin/halqa_students_bottom_sheet.dart';

class ManageHalqasScreen extends StatefulWidget {
  const ManageHalqasScreen({super.key});

  @override
  State<ManageHalqasScreen> createState() => _ManageHalqasScreenState();
}

class _ManageHalqasScreenState extends State<ManageHalqasScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      provider.refreshHalqas();
      if (provider.teachers.isEmpty || provider.supervisors.isEmpty) {
        provider.refreshPersons(silent: true);
      }
      if (provider.semesters.isEmpty) {
        provider.refreshAcademicData(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HalqaModel> _filterHalqas(List<HalqaModel> halqas) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return halqas;

    return halqas.where((halqa) {
      final teacherName = halqa.teacher?.fullName.toLowerCase() ?? "";
      return halqa.name.toLowerCase().contains(query) ||
          teacherName.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final filteredHalqas = _filterHalqas(provider.halqas);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "إدارة الحلقات القرآنية",
          style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      drawer: const AppSharedDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showHalqaFormBottomSheet(context),
        icon: const Icon(Icons.add),
        label: const Text(
          "إضافة حلقة جديدة",
          style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: "ابحث باسم الحلقة أو اسم الأستاذ...",
                hintStyle: const TextStyle(fontFamily: "Cairo", fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = "");
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.indigo, width: 2),
                ),
              ),
            ),
          ),
          if (provider.error != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontFamily: "Cairo",
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    onPressed: () => provider.clearError(),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildContent(provider, filteredHalqas)),
        ],
      ),
    );
  }

  Widget _buildContent(
    AdminProvider provider,
    List<HalqaModel> filteredHalqas,
  ) {
    if (provider.isHalqasLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.indigo),
      );
    }

    if (filteredHalqas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.layers_clear, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              _searchQuery.isNotEmpty
                  ? "لا توجد نتائج مطابقة لبحثك"
                  : "لا يوجد حلقات مسجلة حاليا في النظام",
              style: TextStyle(
                fontFamily: "Cairo",
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 80),
      itemCount: filteredHalqas.length,
      itemBuilder: (context, index) {
        final halqa = filteredHalqas[index];
        return HalqaCard(
          halqa: halqa,
          onEdit: () => showHalqaFormBottomSheet(context, halqa: halqa),
          onDelete: () => _confirmDeleteDialog(context, halqa),
          onManageStudents: () => showHalqaStudentsBottomSheet(context, halqa),
        );
      },
    );
  }

  void _confirmDeleteDialog(BuildContext context, HalqaModel halqa) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<AdminProvider>(
          builder: (context, provider, child) {
            return AlertDialog(
              title: const Text(
                "تنبيه جودة حرج!",
                style: TextStyle(
                  fontFamily: "Cairo",
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
              content: Text(
                "هل أنت متأكد حتماً من حذف حلقة [${halqa.name}]؟ سيترتب على هذا الإجراء عزل الطلاب المرتبطين بها مؤقتاً.",
                style: const TextStyle(fontFamily: "Cairo", fontSize: 13),
                textAlign: TextAlign.right,
              ),
              actions: [
                TextButton(
                  onPressed: provider.isMutationLoading
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text(
                    "إلغاء",
                    style: TextStyle(fontFamily: "Cairo", color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: provider.isMutationLoading
                      ? null
                      : () async {
                          final success = await provider.deleteHalqa(halqa.id);
                          if (context.mounted && success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "تم حذف الحلقة القرآنية من سجلات النظام بأمان.",
                                  style: TextStyle(fontFamily: "Cairo"),
                                ),
                                backgroundColor: Colors.black87,
                              ),
                            );
                          }
                        },
                  child: provider.isMutationLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "نعم احذف حتما",
                          style: TextStyle(
                            fontFamily: "Cairo",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
