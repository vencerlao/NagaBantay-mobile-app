import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _oldPasswordController =
  TextEditingController();
  final TextEditingController _newPasswordController =
  TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool get _hasMinLength =>
      _newPasswordController.text.length >= 8;

  bool get _hasLettersAndNumbers =>
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(
        _newPasswordController.text,
      );

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Password Changed',
                  style: TextStyle(
                    color: Color(0xFF06370b),
                    fontVariations: [FontVariation('wght', 700)],
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your password has been updated successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF06370b),
                    fontVariations: [FontVariation('wght', 400)],
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF255e1f),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontVariations: [FontVariation('wght', 500)],
                        fontFamily: 'Montserrat',
                        fontSize: 16,
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
  }

  InputDecoration _inputDecoration(String hint, bool obscure, VoidCallback onTap) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFF06370b).withValues(alpha: 0.5),
        fontFamily: 'Montserrat',
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFFb0ceac),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF06370b), width: 1),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          color: const Color(0xFF06370b),
          size: 20,
        ),
        onPressed: onTap,
      ),
      errorStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontVariations: [FontVariation('wght', 500)],
        color: Colors.redAccent,
        fontSize: 12,
      ),
    );
  }

  Widget _rule(bool valid, String text) {
    return Row(
      children: [
        Icon(
          valid ? Icons.check_circle : Icons.cancel,
          size: 14,
          color: valid ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF06370b),
            fontFamily: 'Montserrat',
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: const Color(0xFF06370b),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Color(0xFF06370b),
            fontVariations: [FontVariation('wght', 700)],
            fontFamily: 'Montserrat',
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create a new password',
                  style: TextStyle(
                    color: Color(0xFF06370b),
                    fontVariations: [FontVariation('wght', 500)],
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),

                const Text('Old Password',
                    style: TextStyle(
                        color: Color(0xFF06370b),
                        fontFamily: 'Montserrat')),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: _obscureOld,
                  decoration: _inputDecoration(
                    'Old Password',
                    _obscureOld,
                        () => setState(() => _obscureOld = !_obscureOld),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty
                      ? 'Old password is required'
                      : null,
                ),

                const SizedBox(height: 16),

                const Text('New Password',
                    style: TextStyle(
                        color: Color(0xFF06370b),
                        fontFamily: 'Montserrat')),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDecoration(
                    'New Password',
                    _obscureNew,
                        () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'New password is required';
                    }
                    if (!_hasMinLength || !_hasLettersAndNumbers) {
                      return 'Password does not meet requirements';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),
                _rule(_hasMinLength, 'At least 8 characters'),
                _rule(_hasLettersAndNumbers, 'Must include letters and numbers'),

                const SizedBox(height: 16),

                const Text('Confirm Password',
                    style: TextStyle(
                        color: Color(0xFF06370b),
                        fontFamily: 'Montserrat')),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: _inputDecoration(
                    'Confirm Password',
                    _obscureConfirm,
                        () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF06370b),
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF255e1f),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                color: Colors.white,
                fontVariations: [FontVariation('wght', 500)],
                fontFamily: 'Montserrat',
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
