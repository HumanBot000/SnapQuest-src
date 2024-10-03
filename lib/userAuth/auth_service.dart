import 'dart:developer';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite_auth_kit/appwrite_auth_kit.dart';
import 'package:appwrite/models.dart'
    as models; // Import models to use User model

class AuthService {
  final Client client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('66fdb5920016d9270ac9');
  late Account account;

  AuthService() {
    account = Account(client);
  }

  Future<void> loginWithGitHub() async {
    try {
      await account.createOAuth2Session(
        provider: OAuthProvider.github,
        success:
            'appwritehackathon://callback', // replace with your deep link URL
        failure: 'appwritehackathon://error', // replace with your error URL
      );
    } catch (e) {
      log("Error on login (gh): $e", error: e);
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
