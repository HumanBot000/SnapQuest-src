import 'package:flutter/material.dart';
import 'package:appwrite_hackathon_2024/userAuth/auth_service.dart';
import 'package:appwrite_hackathon_2024/userAuth/login_screen.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(const MyApp());
}

final logger = Logger();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.blueAccent.shade400),
        useMaterial3: true,
      ),
      home: LoginScreen(authService: authService),
    );
  }
}
