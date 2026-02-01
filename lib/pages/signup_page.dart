import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nagabantay_mobile_app/pages/setup_page.dart';
import 'package:nagabantay_mobile_app/pages/login_page.dart';
import 'package:nagabantay_mobile_app/widgets/responsive_scaffold.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  String? _phoneError;
  bool _isLoading = false; // Loading state for button

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _normalizePhone(String input) {
    // remove non-digit characters
    final digitsOnly = input.replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly;
  }

  Future<bool> _checkUserExists(String phoneNumber) async {
    try {
      final normalized = _normalizePhone(phoneNumber);
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(normalized)
          .get();
      return doc.exists;
    } catch (e) {
      // Optional: handle error
      return false;
    }
  }

  void _onContinue() async {
    setState(() {
      _phoneError = null;
    });

    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      setState(() => _phoneError = 'Please enter your phone number');
      return;
    } else if (phoneNumber.length < 9) {
      setState(() => _phoneError = 'Invalid phone number');
      return;
    }

    setState(() => _isLoading = true);

    final exists = await _checkUserExists(phoneNumber);

    setState(() => _isLoading = false);

    final normalized = _normalizePhone(phoneNumber);

    if (exists) {
      // Existing user -> go to Login page, pass normalized phone
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(initialPhone: normalized),
        ),
      );
    } else {
      // New user -> go to Setup page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SetupPage(phoneNumber: normalized),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use ResponsiveScaffold to avoid bottom overflow across devices
    return ResponsiveScaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = math.min(constraints.maxWidth, 720);
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      // Logo + Title
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/nagabantay_logo.png',
                              height: 60,
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'NagaBantay',
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 28,
                                    color: Color(0xFF23552C),
                                    fontVariations: [FontVariation('wght', 700)],
                                  ),
                                ),
                                Text(
                                  'Parabantay nin gabos na barangay',
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    color: Color(0xFF23552C),
                                    fontVariations: [FontVariation('wght', 400)],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Welcome to Nagabantay!',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            color: Color(0xFF23552C),
                            fontVariations: [FontVariation('wght', 700)],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Enter your phone number to log-in to an existing account or instantly set up your new account.',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: Color(0xFF23552C),
                            fontVariations: [FontVariation('wght', 400)],
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Phone Number',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            color: Color(0xFF23552C),
                            fontVariations: [FontVariation('wght', 400)],
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Phone input row
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB0CEAC),
                                  border: Border.all(color: const Color(0xFF23552C)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '+63',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    fontVariations: [FontVariation('wght', 400)],
                                    color: Color(0xFF23552C),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 52,
                                  child: TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                      color: Color(0xFF23552C),
                                      fontVariations: [FontVariation('wght', 400)],
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '9xx xxx xxxx',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        fontVariations: const [FontVariation('wght', 400)],
                                        color: const Color(0xFF23552C).withAlpha(128),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFB0CEAC),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Color(0xFF23552C)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Color(0xFF23552C), width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (_phoneError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 4),
                              child: Text(
                                _phoneError!,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontVariations: [FontVariation('wght', 400)],
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF255E1F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Continue',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Align(
                        alignment: Alignment.center,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            text: 'By continuing, you agree to our ',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11,
                              color: Color(0xFF23552C),
                              fontVariations: [FontVariation('wght', 400)],
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 11,
                                  color: Colors.blue,
                                  fontVariations: [FontVariation('wght', 400)],
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(
                                text: ' and verify that you have read our',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 11,
                                  color: Color(0xFF23552C),
                                  fontVariations: [FontVariation('wght', 400)],
                                ),
                              ),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 11,
                                  color: Colors.blue,
                                  fontVariations: [FontVariation('wght', 400)],
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
