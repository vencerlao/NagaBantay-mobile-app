import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nagabantay_mobile_app/pages/signup_page.dart';
import 'package:nagabantay_mobile_app/widgets/responsive_scaffold.dart';

class SetupPage extends StatefulWidget {
  final String phoneNumber; // from SignUp page (normalized digits)
  const SetupPage({super.key, required this.phoneNumber});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _PasswordValidationRow extends StatelessWidget {
  final bool isValid;
  final String text;
  const _PasswordValidationRow({required this.isValid, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: Color(0xFF23552C),
            fontVariations: [FontVariation('wght', 400)],
          ),
        ),
      ],
    );
  }
}

class _SetupPageState extends State<SetupPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _phoneController;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _firstNameError;
  String? _lastNameError;
  String? _passwordError;
  String? _barangayError;
  String? _selectedBarangay;

  bool get hasMinLength => _passwordController.text.length >= 8;
  bool get hasNumber => _passwordController.text.contains(RegExp(r'[0-9]'));

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.phoneNumber);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _normalizePhone(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _saveUserData() async {
    setState(() {
      _firstNameError =
      _firstNameController.text.isEmpty ? 'First name is required' : null;
      _lastNameError =
      _lastNameController.text.isEmpty ? 'Last name is required' : null;
      _passwordError =
      _passwordController.text.isEmpty ? 'Password is required' : null;
      _barangayError =
      _selectedBarangay == null ? 'Please select a barangay' : null;
    });

    if (_firstNameError != null ||
        _lastNameError != null ||
        _passwordError != null ||
        _barangayError != null) return;

    setState(() => _isLoading = true);

    try {
      final normalized = _normalizePhone(_phoneController.text.trim());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(normalized) // doc ID = normalized phone
          .set({
        'phone': normalized,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'password': _passwordController.text.trim(),
        'barangay': _selectedBarangay!,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => _isLoading = false);

      // Show the success dialog instead of SnackBar
      showDialog(
        context: context,
        barrierDismissible: false, // force user to tap Done
        builder: (context) {
          return Dialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF23552C),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Account Created Successfully',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      color: Color(0xFF23552C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        // Close the dialog first
                        Navigator.of(context).pop();

                        // Navigate to SignUpPage and clear the navigation stack so
                        // the app returns to the signup flow reliably.
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF23552C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving data. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            PhosphorIcons.caretLeft,
            size: 22.0,
            color: const Color(0xff06370b),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = math.min(constraints.maxWidth, 720).toDouble();
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      const Text(
                        'Complete your\naccount setup',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 24,
                          color: Color(0xFF23552C),
                          fontVariations: [FontVariation('wght', 700)],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Phone Number
                      const Text('Phone Number',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color(0xFF23552C),
                            fontVariations: [FontVariation('wght', 400)],
                          )),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                  color: Color(0xFF23552C)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    color: Color(0xFF23552C),
                                    fontVariations: [FontVariation('wght', 400)]),
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
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // First Name
                      const Text('First Name', style: TextStyle(
                        fontFamily: 'Montserrat', fontSize: 14, color: Color(0xFF23552C),
                        fontVariations: [FontVariation('wght', 400)],
                      )),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 42,
                        child: TextFormField(
                          controller: _firstNameController,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color(0xFF23552C),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your first name',
                            hintStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: const Color(0xFF23552C).withAlpha(128),
                              fontVariations: const [FontVariation('wght', 400)],
                            ),
                            filled: true,
                            fillColor: const Color(0xFFB0CEAC),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Color(0xFF23552C)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFF23552C), width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                        ),
                      ),

                      if (_firstNameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            _firstNameError!,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: Colors.red,
                              fontVariations: [FontVariation('wght', 400)],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Last Name
                      const Text('Last Name', style: TextStyle(
                        fontFamily: 'Montserrat', fontSize: 14, color: Color(0xFF23552C),
                        fontVariations: [FontVariation('wght', 400)],
                      )),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 42,
                        child: TextFormField(
                          controller: _lastNameController,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color(0xFF23552C),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your last name',
                            hintStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: const Color(0xFF23552C).withAlpha(128),
                              fontVariations: const [FontVariation('wght', 400)],
                            ),
                            filled: true,
                            fillColor: const Color(0xFFB0CEAC),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Color(0xFF23552C)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFF23552C), width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                        ),
                      ),

                      if (_lastNameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            _lastNameError!,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: Colors.red,
                              fontVariations: [FontVariation('wght', 400)],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Password
                      const Text('Password', style: TextStyle(
                        fontFamily: 'Montserrat', fontSize: 14, color: Color(0xFF23552C),
                        fontVariations: [FontVariation('wght', 400)],
                      )),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 42,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Color(0xFF23552C),
                            fontVariations: [FontVariation('wght', 400)],
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: const Color(0xFF23552C).withAlpha(128),
                              fontVariations: const [FontVariation('wght', 400)],
                            ),
                            filled: true,
                            fillColor: const Color(0xFFB0CEAC),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Color(0xFF23552C)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFF23552C), width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF23552C)),
                              onPressed: () => setState(() {
                                _obscurePassword = !_obscurePassword;
                              }),
                            ),
                          ),
                        ),
                      ),

                      if (_passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            _passwordError!,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: Colors.red,
                              fontVariations: [FontVariation('wght', 400)],
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),
                      _PasswordValidationRow(
                          isValid: hasMinLength, text: 'At least 8 characters'),
                      const SizedBox(height: 4),
                      _PasswordValidationRow(isValid: hasNumber, text: 'Contains a number'),

                      // Barangay
                      const SizedBox(height: 16),
                      const Text('Barangay', style: TextStyle(
                        fontFamily: 'Montserrat', fontSize: 14, color: Color(0xFF23552C),
                        fontVariations: [FontVariation('wght', 400)],
                      )),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 42,
                        child: DropdownSearch<String>(
                          items: const [
                            'Abella','Bagumbayan Norte','Bagumbayan Sur','Balatas','Calauag',
                            'Cararayan','Carolina','Conception Grande','Conception Pequeña',
                            'Dayangdang','Del Rosario','Dinaga','Igualdad Interior','Lerma',
                            'Liboton','Mabolo','Pacol','Panicuason','Peñafrancia','Sabang',
                            'San Felipe','San Francisco','San Isidro','Santa Cruz','Tabuco',
                            'Tinago','Triangulo'
                          ],
                          selectedItem: _selectedBarangay,
                          onChanged: (value) => setState(() => _selectedBarangay = value),
                          dropdownButtonProps: const DropdownButtonProps(
                              icon: Icon(PhosphorIcons.caretDownFill,
                                  size: 16.0, color: Color(0xff06370b))),
                          dropdownBuilder: (context, selectedItem) {
                            return Text(
                              selectedItem ?? 'Select your barangay',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontVariations: const [FontVariation('wght', 400)],
                                color: selectedItem == null
                                    ? const Color(0xFF23552C).withAlpha(128)
                                    : const Color(0xFF23552C),
                              ),
                            );
                          },
                        ),
                      ),

                      if (_barangayError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            _barangayError!,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: Colors.red,
                              fontVariations: [FontVariation('wght', 400)],
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 35,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveUserData,
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
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Confirm'),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ), // Column
                ), // Form
              ), // SingleChildScrollView
            ), // ConstrainedBox
          ); // Center
        }, // builder
      ), // LayoutBuilder
    ); // ResponsiveScaffold
  } // build
} // class
