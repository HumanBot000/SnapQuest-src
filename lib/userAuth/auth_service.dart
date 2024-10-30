import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Future<bool> userIsLoggedIn() async {
    models.User? user = await getUser();
    return user != null;
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
      await _saveLoginStateLocally();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Home(user: user)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error during GitHub login! Please try again")));
      logger.e("Error during GitHub login", e);
    }
  }

  Future<void> loginWithDiscord(BuildContext context) async {
    try {
      await account.createOAuth2Session(provider: OAuthProvider.discord);
      var user = await getUser();
      if (user == null) {
        logger.w("User not found after Discord login");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Error during Discord login! Please try again")));
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Home(user: user)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error during Discord login! Please try again")));
      logger.e("Error during Discord login", e);
    }
  }

  Future<models.User?> getUser() async {
    try {
      models.User? user = await account.get();
      return user;
    } on AppwriteException {
      //This gets thrown when the user is not logged in (Appwrite doesn't provide another way to check this)
      return null;
    }
  }

  Future<void> logout() async {
    await account.deleteSession(sessionId: 'current');
    await _clearLoginStateLocally();
  }

  Future<void> _saveLoginStateLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
  }

  Future<void> _clearLoginStateLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('isLoggedIn');
  }

  Future<bool> getSavedLoginStateLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
