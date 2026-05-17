import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_providers.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة الطلاب"),
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.person_add),
        label: const Text("إضافة طالب"),
      ),

      body: Column(
        children: [
          _searchBar(),
          Expanded(
            child: provider.loading && provider.students.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => provider.loadAll(),
                    child: _studentsList(provider),
                  ),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // شريط البحث العصري
  // -----------------------------
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "ابحث بالاسم أو الهاتف...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (v) => setState(() => _query = v.trim()),
      ),
    );
  }

  // -----------------------------
  // قائمة الطلاب
  // -----------------------------
  Widget _studentsList(AdminProvider provider) {
    final filtered = provider.students.where((s) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return s.fullName.toLowerCase().contains(q) ||
          (s.user?.phone?.contains(q) ?? false);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("لا توجد نتائج"));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final student = filtered[index];

        return Container(
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
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo.shade100,
              child: const Icon(Icons.person, color: Colors.indigo),
            ),
            title: Text(
              student.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(student.user?.phone ?? "لا يوجد رقم"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        );
      },
    );
  }
}
