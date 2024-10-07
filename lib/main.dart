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
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFfd366e),
          onPrimary: Colors.white,
          secondary: Color(0xFF00a5c2),
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.black26,
          onSurface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: LoginScreen(authService: authService),
    );
  }
}
