import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_center_app/presentation/providers/auth_provider.dart';
// import '../../presentation/providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final success = await auth.changePassword(
      _oldController.text.trim(),
      _newController.text.trim(),
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تغيير كلمة المرور بنجاح"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? "فشل تغيير كلمة المرور"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("تغيير كلمة المرور")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _oldController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "كلمة المرور الحالية", border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.isEmpty) ? "الرجاء إدخال كلمة المرور الحالية" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "كلمة المرور الجديدة", border: OutlineInputBorder()),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "الرجاء إدخال كلمة المرور الجديدة";
                      if (v.length < 6) return "يجب أن تكون كلمة المرور 6 أحرف على الأقل";
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "تأكيد كلمة المرور", border: OutlineInputBorder()),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "الرجاء تأكيد كلمة المرور";
                      if (v != _newController.text) return "كلمة المرور غير متطابقة";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  auth.isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => _save(context),
                            child: const Text("حفظ", style: TextStyle(fontSize: 16)),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
