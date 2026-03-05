import 'package:flutter/material.dart';
import 'package:test_gimmo_2/screens/homescreen.dart';
import 'package:test_gimmo_2/screens/loginscreen.dart';
import 'package:test_gimmo_2/storage.dart';

import 'screens/signupscreen.dart';

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
