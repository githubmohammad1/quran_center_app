import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/data/models/halqa_model.dart';
import 'package:quran_center_app/data/models/person_model.dart';
import '../../providers/teacher_provider.dart';


class TeacherAddMemorizationScreen extends StatefulWidget {
 
final Map<String, dynamic> args;
  const TeacherAddMemorizationScreen({super.key, required this.args});

  @override
  State<TeacherAddMemorizationScreen> createState() => _TeacherAddMemorizationScreenState();
}

class _TeacherAddMemorizationScreenState extends State<TeacherAddMemorizationScreen> {
  final pageFromController = TextEditingController();
  final pageToController = TextEditingController();
late PersonModel student;
late HalqaModel halqa;

@override
void initState() {
  super.initState();
  student = widget.args["student"] as PersonModel;
  halqa = widget.args["halqa"] as HalqaModel;
}

  String? selectedGrade;

  // حساب رقم الجزء من رقم الصفحة
  int getJuzFromPage(int page) {
    return ((page - 1) ~/ 20) + 1; // كل جزء = 20 صفحة
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();

    return Scaffold(
      // appBar: AppBar(
      //   title: Text("تسجيل تسميع — ${widget.student.fullName}"),
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black87,
      //   elevation: 0,
      // ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _studentCard(),
          const SizedBox(height: 20),
          _pageInput(),
          const SizedBox(height: 20),
          _gradeSelector(),
          const SizedBox(height: 30),
          _saveButton(provider),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // بطاقة الطالب
  // ---------------------------------------------------------
  Widget _studentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.person, color: Colors.blue.shade700, size: 32),
          ),
          const SizedBox(width: 16),
      
           
       
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // إدخال الصفحات + حساب الجزء تلقائيًا
  // ---------------------------------------------------------
  Widget _pageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("الصفحات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: pageFromController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "من الصفحة",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: pageToController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "إلى الصفحة",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (pageFromController.text.isNotEmpty)
            Text(
              "الجزء: ${getJuzFromPage(int.tryParse(pageFromController.text) ?? 1)}",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // اختيار التقدير
  // ---------------------------------------------------------
  Widget _gradeSelector() {
    final grades = ["A", "B", "C", "D", "F"];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("التقدير", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            children: grades.map((g) {
              final selected = selectedGrade == g;

              return InkWell(
                onTap: () => setState(() => selectedGrade = g),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? Colors.blue.shade100 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? Colors.blue : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    g,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.blue.shade700 : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // زر الحفظ
  // ---------------------------------------------------------
  Widget _saveButton(TeacherProvider provider) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade700,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () async {
        final from = int.tryParse(pageFromController.text);
        final to = int.tryParse(pageToController.text);

        if (from == null || to == null || selectedGrade == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("يرجى إدخال الصفحات واختيار التقدير")),
          );
          return;
        }

  final args = ModalRoute.of(context)!.settings.arguments as Map;
final student = args["student"] as PersonModel;
final halqa = args["halqa"] as HalqaModel;

final data = {
  "student": student.id,
  "semester": halqa.semester?.id,
  "page_from": from,
  "page_to": to,
  "grade": selectedGrade,
};




        final success = await provider.addMemorization(data);


        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم تسجيل التسميع بنجاح")),
          );
          Navigator.pop(context);
        }
      },
      child: const Text("حفظ التسميع", style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }

  // ---------------------------------------------------------
  // صندوق تصميم موحد
  // ---------------------------------------------------------
  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
