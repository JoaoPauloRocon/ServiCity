import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:servicity/screens/home/home_screen.dart';
import 'package:servicity/screens/login/LoginScreen.dart';
import 'package:servicity/screens/login/SignupScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServiCity',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/signup': (context) => SignupScreen(), 
      },
    );
  }
}
