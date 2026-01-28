import 'package:flutter/material.dart';
import 'package:nagabantay_mobile_app/pages/setup_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  String? _phoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onContinue() {
    setState(() {
      if (_phoneController.text.isEmpty) {
        _phoneError = 'Please enter your phone number';
      } else if (_phoneController.text.length < 10) {
        _phoneError = 'Invalid phone number';
      } else {
        _phoneError = null;
      }
    });

    if (_phoneError == null) {
      final phoneNumber = _phoneController.text.trim();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SetupPage(phoneNumber: phoneNumber),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              SizedBox(height: screenHeight * 0.15),

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
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 28,
                            color: const Color(0xFF23552C),
                            fontVariations: const [
                              FontVariation('wght', 700),
                            ],
                          ),
                        ),

                        Text(
                          'Parabantay nin gabos na barangay',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: const Color(0xFF23552C),
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.08),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Welcome to Nagabantay!',
                  style: TextStyle(fontFamily: 'Montserrat',
                    fontSize: 18,
                    color: Color(0xFF23552C),
                    fontVariations: [
                      FontVariation('wght', 700),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: screenHeight * 0.015),

              const Align(
                alignment: Alignment.center,
                child: Text(
                  'Enter your phone number to log-in to an existing account or instantly set up your new account.',
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 12,
                    color: Color(0xFF23552C),
                    fontVariations: [
                      FontVariation('wght', 400),
                    ],),
                  textAlign: TextAlign.left,
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Phone Number',
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 16,
                    color: Color(0xFF23552C),
                    fontVariations: [
                      FontVariation('wght', 400),
                    ],),
                  textAlign: TextAlign.left,
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

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
                            height: 52, // 🔒 fixed height — no jumping
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
                                  color: const Color(0xFF23552C).withValues(alpha: 0.5),
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
                                contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                            fontVariations: [
                              FontVariation('wght', 400),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

              SizedBox(height: screenHeight * 0.05),

              SizedBox(
                width: double.infinity,
                height: 35,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF255E1F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
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

              SizedBox(height: screenHeight * 0.2),

              Align(
                alignment: Alignment.center,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'By continuing, you agree to our ',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      color: Color(0xFF23552C),
                      fontVariations: [FontVariation('wght', 400)],
                    ),
                    children: const [
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

              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
