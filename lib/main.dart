import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appwrite_hackathon_2024/userAuth/auth_service.dart';
import 'package:appwrite_hackathon_2024/userAuth/login_screen.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

import 'other/ExamplePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();
  String? _deeplinkMessage;
  late StreamSubscription<String?> _sub;

  @override
  void initState() {
    super.initState();
    _initDeeplinkListener();
  }

  void _initDeeplinkListener() async {
    _sub = getLinksStream().listen((String? link) async {
      if (link != null) {
        if (link.startsWith('appwritehackathon://callback')) {
          final user = await authService.getUser();
          if (user != null) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => Example(user: user),
            ));
          }
        } else if (link.startsWith('appwritehackathon://error')) {
          debugPrint('Login failed, redirecting to error page.');
        }
      }
    }, onError: (err) {
      debugPrint('Deeplink error : $err');
    });
  }

  @override
  void dispose() {
    _sub.cancel(); // Cancel the stream subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(authService: authService),
    );
  }
}
