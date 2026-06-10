import 'package:flutter/material.dart';
import '../../../data/models/halqa_model.dart';

class HalqaCard extends StatelessWidget {
  final HalqaModel halqa;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManageStudents;

  const HalqaCard({
    super.key,
    required this.halqa,
    required this.onEdit,
    required this.onDelete,
    required this.onManageStudents,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.indigo,
          child: Icon(Icons.group, color: Colors.white),
        ),
        title: Text(
          halqa.name,
          style: const TextStyle(
            fontFamily: "Cairo",
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          "المحفّظ: ${halqa.teacher?.fullName ?? 'غير معيّن'} | عدد الطلاب: ${halqa.studentsCount}",
          style: TextStyle(
            fontFamily: "Cairo",
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
                  label: const Text(
                    "تعديل الحلقة",
                    style: TextStyle(color: Colors.orange, fontFamily: "Cairo", fontSize: 13),
                  ),
                  onPressed: onEdit,
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  icon: const Icon(Icons.school, color: Colors.blue, size: 18),
                  label: const Text(
                    "إدارة الطلاب",
                    style: TextStyle(color: Colors.blue, fontFamily: "Cairo", fontSize: 13),
                  ),
                  onPressed: onManageStudents,
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  icon: const Icon(Icons.delete_forever, color: Colors.red, size: 18),
                  label: const Text(
                    "حذف الحلقة",
                    style: TextStyle(color: Colors.red, fontFamily: "Cairo", fontSize: 13),
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
