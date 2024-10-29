import 'package:SnapQuest/userAuth/auth_service.dart';
import 'package:SnapQuest/userAuth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'game/home.dart';

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
          surface: Colors.black12,
          onSurface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: authService.userIsLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data == true) {
            return FutureBuilder(
              future: authService.getUser(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting ||
                    userSnapshot.hasError) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (userSnapshot.hasData) {
                  return Home(user: userSnapshot.data!);
                } else {
                  return LoginScreen(authService: authService);
                }
              },
            );
          } else {
            return LoginScreen(authService: authService);
          }
        },
      ),
    );
  }
}
