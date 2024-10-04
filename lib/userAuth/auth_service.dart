import 'dart:developer';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite_auth_kit/appwrite_auth_kit.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../other/ExamplePage.dart'; // Import models to use User model

class AuthService {
  final Client client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('66fdb5920016d9270ac9');
  late Account account;

  AuthService() {
    account = Account(client);
  }

  final logger = Logger();

  Future<void> loginWithGitHub(BuildContext context) async {
    try {
      await account.createOAuth2Session(provider: OAuthProvider.github);
      var user = await getUser();
      if (user == null) {
        logger.w("User not found after GitHub login");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error during GitHub login! Please try again")));
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Example(user: user)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error during GitHub login! Please try again")));
      logger.e("Error during GitHub login", e);
    }
  }

  Future<models.User?> getUser() async {
    try {
      return await account.get();
    } catch (e) {
      log("Error on fetching user: $e", error: e);
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      log("Error at logout: $e", error: e);
    }
  }
}
