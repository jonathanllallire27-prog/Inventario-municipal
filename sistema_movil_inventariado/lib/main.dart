import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Inventario Municipal',
      theme: AppTheme.themeData,
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
