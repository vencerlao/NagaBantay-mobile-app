import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';

class SetupPage extends StatefulWidget {
  final String phoneNumber; // add this

  const SetupPage({super.key, required this.phoneNumber});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _PasswordValidationRow extends StatelessWidget {
  final bool isValid;
  final String text;

  const _PasswordValidationRow({
    required this.isValid,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 16,
        ),
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
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.phoneNumber);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  String? _firstNameError;
  String? _lastNameError;
  String? _passwordError;
  String? _phoneError;
  String? _barangayError;
  String? _selectedBarangay;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool get hasMinLength => _passwordController.text.length >= 8;
  bool get hasNumber =>
      _passwordController.text.contains(RegExp(r'[0-9]'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'Complete your\naccount setup',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24,
                      color: Color(0xFF23552C),
                      fontVariations: [
                        FontVariation('wght', 700),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Phone label
                  const Text('Phone Number',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Color(0xFF23552C),
                      fontVariations: [
                        FontVariation('wght', 400),
                      ],
                    )
                  ),
                  const SizedBox(height: 10),

                  // Phone row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
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
                            fontVariations: [
                              FontVariation('wght', 400),
                            ],
                            color: Color(0xFF23552C),
                          ),
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
                              fontVariations: [FontVariation('wght', 400)],
                              color: Color(0xFF23552C),
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text('First Name',
                    style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: Color(0xFF23552C),
                    fontVariations: [
                      FontVariation('wght', 400),
                    ],
                    )
                  ),
                  const SizedBox(height: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              color: const Color(0xFF23552C).withValues(alpha: 0.5),
                              fontVariations: [
                                FontVariation('wght', 400),
                              ],
                            ),
                            filled: true,
                            fillColor: const Color(0xFFB0CEAC),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFF23552C)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Color(0xFF23552C), width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                              fontVariations: [
                                FontVariation('wght', 400),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text('Last Name',
                    style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: Color(0xFF23552C),
                    fontVariations: [
                      FontVariation('wght', 400),
                    ],
                    )
                  ),

                  const SizedBox(height: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              color: const Color(0xFF23552C).withValues(alpha: 0.5),
                              fontVariations: [
                                FontVariation('wght', 400),
                              ],
                            ),
                            filled: true,
                            fillColor: const Color(0xFFB0CEAC),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFF23552C)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Color(0xFF23552C), width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                              fontVariations: [
                                FontVariation('wght', 400),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text('Password',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Color(0xFF23552C),
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                      ),
                  ),

                  const SizedBox(height: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 42,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontVariations: [FontVariation('wght', 400)],
                            color: Color(0xFF23552C),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
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
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF23552C),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
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
                              fontVariations: [
                                FontVariation('wght', 400),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  _PasswordValidationRow(
                    isValid: hasMinLength,
                    text: 'At least 8 characters',
                  ),
                  const SizedBox(height: 4),
                  _PasswordValidationRow(
                    isValid: hasNumber,
                    text: 'Contains a number',
                  ),

                  const SizedBox(height: 16),

                  const Text('Barangay',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Color(0xFF23552C),
                      fontVariations: [
                        FontVariation('wght', 400),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 42,
                        child: DropdownSearch<String>(
                          items: const <String>[
                            'Abella',
                            'Bagumbayan Norte',
                            'Bagumbayan Sur',
                            'Balatas',
                            'Calauag',
                            'Cararayan',
                            'Carolina',
                            'Conception Grande',
                            'Conception Pequeña',
                            'Dayangdang',
                            'Del Rosario',
                            'Dinaga',
                            'Igualdad Interior',
                            'Lerma',
                            'Liboton',
                            'Mabolo',
                            'Pacol',
                            'Panicuason',
                            'Peñafrancia',
                            'Sabang',
                            'San Felipe',
                            'San Francisco',
                            'San Isidro',
                            'Santa Cruz',
                            'Tabuco',
                            'Tinago',
                            'Triangulo',
                          ],
                          selectedItem: _selectedBarangay,
                          onChanged: (value) {
                            setState(() {
                              _selectedBarangay = value;
                            });
                          },

                          dropdownButtonProps: const DropdownButtonProps(
                            icon: Icon(
                              PhosphorIcons.caretDownFill,
                              size: 16.0,
                              color: Color(0xff06370b),
                            ),
                          ),

                          dropdownBuilder: (context, selectedItem) {
                            return Text(
                              selectedItem ?? 'Select your barangay',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontVariations: const [FontVariation('wght', 400)],
                                color: selectedItem == null
                                    ? const Color(0xFF23552C).withValues(alpha: 0.5)
                                    : const Color(0xFF23552C),
                              ),
                            );
                          },

                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            showSelectedItems: true,
                            menuProps: MenuProps(borderRadius: BorderRadius.circular(8)),
                            searchFieldProps: TextFieldProps(
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Color(0xFF23552C),
                                fontVariations: [FontVariation('wght', 400)],
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search barangay',
                                hintStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: const Color(0xFF23552C).withValues(alpha: 0.5),
                                ),
                                contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                            itemBuilder: (context, item, isSelected) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    fontVariations: const [FontVariation('wght', 400)],
                                      color: Color(0xFF23552C),
                                  ),
                                ),
                              );
                            },
                          ),

                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFB0CEAC),
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    ],
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 35,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _firstNameError = _firstNameController.text.isEmpty
                              ? 'First name is required'
                              : null;
                          _lastNameError = _lastNameController.text.isEmpty
                              ? 'Last name is required'
                              : null;
                          _passwordError = _passwordController.text.isEmpty
                              ? 'Password is required'
                              : null;
                          _phoneError = _phoneController.text.isEmpty
                              ? 'Phone number is required'
                              : null;
                          _barangayError = _selectedBarangay == null
                              ? 'Please select a barangay'
                              : null;
                        });

                        if (_firstNameError == null &&
                            _lastNameError == null &&
                            _passwordError == null &&
                            _phoneError == null &&
                            _barangayError == null) {
                        }
                      },

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
                      child: const Text('Confirm'),
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
  }
}