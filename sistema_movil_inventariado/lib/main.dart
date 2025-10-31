import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Inventario Municipal',
      theme: AppTheme.themeData,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
