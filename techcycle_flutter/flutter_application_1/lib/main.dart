import 'package:flutter/material.dart';
import 'pages/auth/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechCycle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginPage(), // ← CORRIGIDO: LoginPage em vez de dashboard_page
      debugShowCheckedModeBanner: false,
    );
  }
}