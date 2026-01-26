import 'package:flutter/material.dart';
import 'pages/signup_page.dart'; // Import your SignUpPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nagabantay Sign-Up',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SignUpPage(), // Your SignUp page as the first screen
    );
  }
}
