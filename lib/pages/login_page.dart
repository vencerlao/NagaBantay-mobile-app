import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:nagabantay_mobile_app/widgets/navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nagabantay_mobile_app/pages/signup_page.dart';


class LoginPage extends StatefulWidget {
  final String? initialPhone;
  const LoginPage({super.key, this.initialPhone});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _phoneError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null) {
      phoneController.text = widget.initialPhone!;
    }
  }

  Future<void> _login() async {
    setState(() {
      _phoneError = phoneController.text.isEmpty ? 'Phone number is required' : null;
      _passwordError = passwordController.text.isEmpty ? 'Password is required' : null;
    });

    if (_phoneError != null || _passwordError != null) return;

    setState(() => _isLoading = true);

    try {
      final normalizedPhone = phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(normalizedPhone)
          .get();

      if (!doc.exists) {
        setState(() {
          _phoneError = 'No account found with this phone number';
          _isLoading = false;
        });
        return;
      }

      final data = doc.data();
      if (data == null || data['password'] != passwordController.text.trim()) {
        setState(() {
          _passwordError = 'Incorrect password';
          _isLoading = false;
        });
        return;
      }

      setState(() => _isLoading = false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const NagabantayNavBar(initialIndex: 0)),
        (route) => false,
      );

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error logging in. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SignUpPage()),
          ),
          icon: Icon(
            PhosphorIcons.caretLeft,
            size: 22.0,
            color: const Color(0xff06370b),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 28,
                    color: Color(0xFF23552C),
                    fontVariations: [FontVariation('wght', 700)],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter your password to continue",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    color: Color(0xFF23552C),
                    fontVariations: [FontVariation('wght', 400)],
                  ),
                ),
                const SizedBox(height: 32),

                const Text("Enter your phone number",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    color: Color(0xFF23552C),
                    fontVariations: [FontVariation('wght', 400)],
                  ),
                ),
                const SizedBox(height: 8),
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
                          child: const Text("+63",
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
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: Color(0xFF23552C),
                              fontVariations: [FontVariation('wght', 400)],
                            ),
                            decoration: InputDecoration(
                              hintText: "9xx xxx xxxx",
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
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_phoneError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _phoneError!,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.red,
                          fontVariations: [FontVariation('wght', 400)],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 20),

                const Text("Password",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    color: Color(0xFF23552C),
                    fontVariations: [FontVariation('wght', 400)],
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Color(0xFF23552C),
                        fontVariations: [FontVariation('wght', 400)],
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter your password",
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
                        suffixIcon: IconButton(
                          icon: _obscurePassword
                              ? Icon(PhosphorIcons.eyeSlash, size: 22.0, color: const Color(0xff06370b))
                              : Icon(PhosphorIcons.eye, size: 22.0, color: const Color(0xff06370b)),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    if (_passwordError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _passwordError!,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.red,
                          fontVariations: [FontVariation('wght', 400)],
                        ),
                      ),
                    ],
                  ],
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      splashFactory: InkRipple.splashFactory,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontVariations: [FontVariation('wght', 400)],
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 45),

                SizedBox(
                  width: double.infinity,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF23552C),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
