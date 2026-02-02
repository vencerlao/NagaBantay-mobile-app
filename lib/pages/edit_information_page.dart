import 'package:flutter/material.dart';

class EditInformationPage extends StatefulWidget {
  const EditInformationPage({super.key});

  @override
  State<EditInformationPage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditInformationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  String? _selectedBarangay;

  final List<String> barangays = [
    'Abella',
    'Bagumbayan Norte',
    'Bagumbayan Sur',
    'Balatas',
    'Calauag',
  ];

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
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Edited Successfully',
                  style: TextStyle(
                      color: Color(0xFF06370b),
                      fontVariations: [FontVariation('wght', 700)],
                      fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Profile updated! Your changes have been saved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF06370b),
                    fontVariations: [FontVariation('wght', 400)],
                    fontSize: 16,
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
                          fontSize: 16),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFF06370b).withValues(alpha: 0.5),
        fontFamily: 'Montserrat',
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFFb0ceac),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF06370b), width: 1),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      errorStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontVariations: [FontVariation('wght', 500)],
        color: Colors.redAccent,
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80.0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
          color: const Color(0xFF06370b),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF06370b),
            fontVariations: [FontVariation('wght', 700)],
            fontFamily: 'Montserrat',
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                  'First Name',
                  style: TextStyle(
                    color: Color(0xFF06370b),
                    fontVariations: [FontVariation('wght', 400)],
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _firstNameController,
                  style: const TextStyle(
                    color: Color(0xFF06370b),
                    fontVariations: [FontVariation('wght', 400)],
                    fontFamily: 'Montserrat',
                  ),
                  decoration: _inputDecoration('Enter First Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Last Name',
                  style: TextStyle(
                    color: Color(0xFF06370b),
                    fontVariations: [FontVariation('wght', 400)],
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _lastNameController,
                  style: const TextStyle(
                    color: Color(0xFF06370b),
                    fontVariations: [FontVariation('wght', 400)],
                    fontFamily: 'Montserrat',
                  ),
                  decoration: _inputDecoration('Enter Last Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Barangay',
                  style: TextStyle(
                    color: Color(0xFF06370b),
                    fontVariations: [FontVariation('wght', 400)],
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedBarangay,
                  style: const TextStyle(
                    color: Color(0xFF06370b),
                    fontVariations: [FontVariation('wght', 400)],
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                  ),
                  decoration: _inputDecoration('Select Your Barangay'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Barangay is required';
                    }
                    return null;
                  },
                  items: barangays
                      .map(
                        (barangay) => DropdownMenuItem(
                      value: barangay,
                      child: Text(barangay),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBarangay = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
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
              'Confirm',
              style: TextStyle(
                  color: Colors.white,
                  fontVariations: [FontVariation('wght', 500)],
                  fontFamily: 'Montserrat',
                  fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}