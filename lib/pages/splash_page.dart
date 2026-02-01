import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nagabantay_mobile_app/pages/signup_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  void _startDelay() {
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SignUpPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/images/nagabantay_logo.png',
            width: 160,
            height: 160,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
