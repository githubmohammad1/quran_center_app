import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/data/models/halqa_model.dart';
import 'package:quran_center_app/data/models/person_model.dart';
import 'package:quran_center_app/presentation/providers/admin_providers.dart';

class ManageMemorizationScreen extends StatefulWidget {
  const ManageMemorizationScreen({super.key});

  @override
  State<ManageMemorizationScreen> createState() =>
      _ManageMemorizationScreenState();
}

class _ManageMemorizationScreenState extends State<ManageMemorizationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  HalqaModel? _selectedHalqa;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AdminProvider>();
      await provider.refreshPersons(silent: true);
      await provider.refreshHalqas(silent: true);
      await provider.refreshAcademicData(silent: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PersonModel> _filteredStudents(AdminProvider provider) {
    final baseList = _selectedHalqa?.students ?? provider.students;
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return baseList;

    return baseList.where((student) {
      return student.fullName.toLowerCase().contains(query) ||
          student.id.toString().contains(query) ||
          (student.user?.phone ?? "").contains(query) ||
          (student.parentPhone ?? "").contains(query);
    }).toList();
  }

  Future<void> _openMemorizationSession(PersonModel student) async {
    await Navigator.pushNamed(
      context,
      "/shared-add-memorization",
      arguments: {
        "student": student,
        "halqa": _selectedHalqa,
        "mode": "admin",
      },
    );

    if (!mounted) return;
    await context.read<AdminProvider>().refreshPersons(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final students = _filteredStudents(provider);
    final isLoading = provider.isPersonsLoading ||
        provider.isHalqasLoading ||
        provider.isAcademicLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("تسجيل جلسات التسميع"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.refreshPersons(silent: true);
          await provider.refreshHalqas(silent: true);
          await provider.refreshAcademicData(silent: true);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _buildFilters(provider),
            const SizedBox(height: 12),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (students.isEmpty)
              _buildEmptyState()
            else
              ...students.map(_buildStudentCard),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(AdminProvider provider) {
    return Column(
      children: [
        DropdownButtonFormField<HalqaModel?>(
          value: _selectedHalqa,
          decoration: const InputDecoration(
            labelText: "تصفية حسب الحلقة",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.group_work),
          ),
          items: [
            const DropdownMenuItem<HalqaModel?>(
              value: null,
              child: Text("جميع الطلاب"),
            ),
            ...provider.halqas.map(
              (halqa) => DropdownMenuItem<HalqaModel?>(
                value: halqa,
                child: Text(halqa.name),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedHalqa = value;
            });
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: "بحث عن طالب",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStudentCard(PersonModel student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.withOpacity(0.1),
          child: const Icon(Icons.menu_book, color: Colors.indigo),
        ),
        title: Text(
          student.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("رقم الطالب: ${student.id}"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _openMemorizationSession(student),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: 120),
      child: Center(
        child: Text(
          "لا يوجد طلاب مطابقون للبحث الحالي.",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
