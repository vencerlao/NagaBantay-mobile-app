import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nagabantay_mobile_app/pages/signup_page.dart';
import 'package:nagabantay_mobile_app/widgets/navigation_bar.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final phoneNumber = snapshot.data?.phoneNumber ?? 'Unknown';
          return NagabantayNavBar(
            initialIndex: 0,
            phoneNumber: phoneNumber,
          );
        }

        return const SignUpPage();
      },
    );
  }
}