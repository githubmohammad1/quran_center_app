import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/guardian_providers.dart';

class GuardianHomeScreen extends StatefulWidget {
  const GuardianHomeScreen({super.key});

  @override
  State<GuardianHomeScreen> createState() => _GuardianHomeScreenState();
}

class _GuardianHomeScreenState extends State<GuardianHomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<GuardianProvider>(context, listen: false).loadChildren();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GuardianProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة ولي الأمر"),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.children.isEmpty
              ? const Center(child: Text("لا يوجد أبناء مسجلون"))
              : ListView.builder(
                  itemCount: provider.children.length,
                  itemBuilder: (context, index) {
                    final child = provider.children[index];
                    return Card(
                      child: ListTile(
                        title: Text(child.fullName),
                        subtitle: Text("الدور: ${child.role}"),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            "/guardian-child-details",
                            arguments: child.id,
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
