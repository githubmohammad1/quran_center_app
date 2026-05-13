import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/single_child_widget.dart';

import '../presentation/providers/auth_provider.dart';
import '../presentation/providers/student_providers.dart';
import '../presentation/providers/guardian_providers.dart';
import '../presentation/providers/admin_providers.dart';

class ProvidersSetup {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => StudentProvider()),
    ChangeNotifierProvider(create: (_) => GuardianProvider()),
    ChangeNotifierProvider(create: (_) => AdminProvider()),
  ];
}
