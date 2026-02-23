import 'package:flutter/material.dart';
import 'package:test_gimmo_2/homescreen.dart';
import 'package:test_gimmo_2/loginscreen.dart';
import 'package:test_gimmo_2/storage.dart';

import 'signupscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await Storage.getToken();

  runApp(MaterialApp(
    home: token != null ? HomeScreen() : LoginScreen(),
    routes: {
      '/login': (_) => LoginScreen(),
      '/home': (_) => HomeScreen(),
      '/signup': (_) => SignupScreen(),
    },
  ));
}
