import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/admin_providers.dart';
import 'StudentTestHistoryScreen.dart';

class AdminTestsScreen extends StatelessWidget {
  const AdminTestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب البيانات الأولية للدش بورد عند بناء الشاشة إذا كانت فارغة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      if (provider.halqas.isEmpty) {
        provider.loadDashboardData();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة اختبارات الطلاب"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBox(context),
          _buildHalqaFilter(context), 
          const Expanded(child: _StudentResultList()),
        ],
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: "ابحث بالاسم أو الرقم التعريف (ID)...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
        ),
        onChanged: (val) => context.read<AdminProvider>().performSearch(val),
      ),
    );
  }

 Widget _buildHalqaFilter(BuildContext context) {
  final provider = context.watch<AdminProvider>(); // [cite: 3]
  
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), 
    child: DropdownButtonFormField<int?>(
      value: provider.selectedHalqaId, // 🚀 ربط القيمة الحالية من الـ Provider [cite: 4]
      decoration: InputDecoration(
        labelText: "تصفية حسب الحلقة", 
        prefixIcon: const Icon(Icons.group_work), 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), 
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05), 
      ),
      hint: const Text("اختر الحلقة لرؤية طلابها"), 
      items: [
        const DropdownMenuItem(value: null, child: Text("جميع الحلقات")), 
        ...provider.halqas.map((halqa) => DropdownMenuItem( // [cite: 5]
          value: halqa.id, 
          child: Text(halqa.name), 
        )),
      ],
      onChanged: (id) {
        // 🚀 استدعاء دالة الفلترة المحلية المحدثة بالـ Provider
        context.read<AdminProvider>().filterByHalqa(id); 
      },
    ),
  );
}}

class _StudentResultList extends StatelessWidget {
  const _StudentResultList();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    // 1. حالة التحميل (Loading State)
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. حالة القائمة الفارغة (Empty State)
    if (provider.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              "لا يوجد طلاب يطابقون بحثك حالياً",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // 3. عرض النتائج (Data Display)
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: provider.searchResults.length,
      itemBuilder: (context, index) {
        final student = provider.searchResults[index];
        
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              child: Text(
                student.id.toString(), 
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
              ),
            ),
            title: Text(
              student.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("رقم الهاتف: ${student.parentPhone ?? 'غير متوفر'}"),
                  Text("الحالة الميدانية: ${student.isActive ? 'نشط' : 'غير نشط'}"),
                ],
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentTestHistoryScreen(student: student),
                ),
              );
            },
          ),
        );
      },
    );
  }
}