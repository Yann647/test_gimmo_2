import 'dart:convert';

import 'package:test_gimmo_2/api_client.dart';
import 'package:test_gimmo_2/api_errors.dart';
import 'package:test_gimmo_2/user.dart';

class ApiAuth {
  // INSCRIPTION
  static Future<User> register({
    required String nom,
    required String prenom,
    required String telephone,
    required String email,
    required String login,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/api/auth/register',
      {
        "nom": nom,
        "prenom": prenom,
        "telephone": telephone,
        "email": email,
        "login": login,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(extractErrorMessage(response));
    }
  }

  // CONNEXION
  static Future<User> login({
    required String login,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/api/auth/login',
      {
        "login": login,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final user = User.fromJson(data);

      // Si plus tard tu ajoutes JWT
      // await Storage.saveToken(data['token']);

      return user;
    } else {
      throw Exception(extractErrorMessage(response));
    }
  }
}
