import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'utils/constants.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize database
  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دليلك الدراسي - University Study Guide',
      debugShowCheckedModeBanner: false,
      theme: AppConstants.getTheme(),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: const LoginScreen(),
    );
  }
}
