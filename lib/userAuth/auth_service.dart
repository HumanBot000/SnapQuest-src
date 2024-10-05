import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite_auth_kit/appwrite_auth_kit.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import '../game/home.dart';
import '../main.dart';

final Client client = Client()
    .setEndpoint('https://cloud.appwrite.io/v1')
    .setProject('66fdb5920016d9270ac9');

class AuthService {
  late Account account;

  AuthService() {
    account = Account(client);
  }

  Future<void> loginWithGitHub(BuildContext context) async {
    try {
      await account.createOAuth2Session(provider: OAuthProvider.github);
      var user = await getUser();
      if (user == null) {
        logger.w("User not found after GitHub login");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Error during GitHub login! Please try again")));
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Home(user: user)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error during GitHub login! Please try again")));
      logger.e("Error during GitHub login", e);
    }
  }

  Future<models.User?> getUser() async {
    try {
      return await account.get();
    } catch (e) {
      logger.e("Error on fetching user: $e");
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      logger.e("Error on logout: $e");
    }
  }
}
