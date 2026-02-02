import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nagabantay_mobile_app/pages/signup_page.dart';
import 'package:nagabantay_mobile_app/widgets/responsive_scaffold.dart';

class SetupPage extends StatefulWidget {
  final String phoneNumber;
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
      _firstNameError = _firstNameController.text.isEmpty ? 'First name is required' : null;
      _lastNameError = _lastNameController.text.isEmpty ? 'Last name is required' : null;
      _passwordError = _passwordController.text.isEmpty ? 'Password is required' : null;
      _barangayError = _selectedBarangay == null ? 'Please select a barangay' : null;
    });

    if (_firstNameError != null || _lastNameError != null || _passwordError != null || _barangayError != null) return;

    setState(() => _isLoading = true);

    try {
      final normalized = _normalizePhone(_phoneController.text.trim());
      await FirebaseFirestore.instance.collection('users').doc(normalized).set({
        'phone': normalized,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'password': _passwordController.text.trim(),
        'barangay': _selectedBarangay!,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF23552C), size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Account Created Successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, color: Color(0xFF23552C), fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF23552C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Done', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error saving data.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SignUpPage()),
          ),
          icon: const Icon(PhosphorIcons.caretLeft, size: 22.0, color: Color(0xff06370b)),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = math.min(constraints.maxWidth, 720).toDouble();

          final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboardPadding),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Complete your\naccount setup',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 24,
                            color: Color(0xFF23552C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildLabel('Phone Number'),
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
                              child: const Text('+63', style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF23552C))),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: _buildTextField(_phoneController, hint: '9xx xxx xxxx', isPhone: true)),
                          ],
                        ),

                        const SizedBox(height: 16),
                        _buildLabel('First Name'),
                        _buildTextField(_firstNameController, hint: 'Enter your first name'),
                        if (_firstNameError != null) _buildErrorText(_firstNameError!),

                        const SizedBox(height: 16),
                        _buildLabel('Last Name'),
                        _buildTextField(_lastNameController, hint: 'Enter your last name'),
                        if (_lastNameError != null) _buildErrorText(_lastNameError!),

                        const SizedBox(height: 16),
                        _buildLabel('Password'),
                        _buildTextField(
                          _passwordController,
                          hint: 'Enter your password',
                          isPassword: true,
                          obscure: _obscurePassword,
                          onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                          onChanged: (_) => setState(() {}),
                        ),
                        if (_passwordError != null) _buildErrorText(_passwordError!),

                        const SizedBox(height: 8),
                        _PasswordValidationRow(isValid: hasMinLength, text: 'At least 8 characters'),
                        const SizedBox(height: 4),
                        _PasswordValidationRow(isValid: hasNumber, text: 'Contains a number'),

                        const SizedBox(height: 16),
                        _buildLabel('Barangay'),
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
                                icon: Icon(PhosphorIcons.caretDownFill, size: 16.0, color: Color(0xff06370b))),
                            dropdownBuilder: (context, selectedItem) => Text(
                              selectedItem ?? 'Select your barangay',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: selectedItem == null ? const Color(0xFF23552C).withAlpha(128) : const Color(0xFF23552C),
                              ),
                            ),
                          ),
                        ),
                        if (_barangayError != null) _buildErrorText(_barangayError!),

                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveUserData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF23552C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Confirm', style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, color: Color(0xFF23552C))),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, {
        required String hint,
        bool isPhone = false,
        bool isPassword = false,
        bool obscure = false,
        VoidCallback? onToggleVisibility,
        Function(String)? onChanged,
      }) {
    return SizedBox(
      height: 42,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        onChanged: onChanged,
        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, color: Color(0xFF23552C)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'Montserrat', fontSize: 14, color: const Color(0xFF23552C).withAlpha(128)),
          filled: true,
          fillColor: const Color(0xFFB0CEAC),
          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF23552C)), borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF23552C), width: 2), borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF23552C), size: 18),
            onPressed: onToggleVisibility,
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildErrorText(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(error, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Colors.red)),
    );
  }
}