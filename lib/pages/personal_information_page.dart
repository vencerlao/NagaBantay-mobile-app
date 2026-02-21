import 'package:flutter/material.dart';
import 'edit_information_page.dart';
import 'change_password_page.dart';

class PersonalInformationPage extends StatelessWidget {
  const PersonalInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        toolbarHeight: 80.0,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF06370b),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          color: const Color(0xFF06370b),
        ),

        title: const Text(
          'Personal Information',

          style: TextStyle(
            color: Color(0xFF06370b),
            fontVariations: [FontVariation('wght', 700)],
            fontFamily: 'Montserrat',
            fontSize: 16,
          ),
        ),
      ),

      body: Column(
        children: [
          _buildItem(
            title: 'Edit Information',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditInformationPage(),
                ),
              );
            },
          ),
          _buildItem(
            title: 'Change Password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            },
          ),
          _buildItem(
            title: 'Delete Account',
            isDestructive: true,
            onTap: () {
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String title,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          title: Text(
            title,
            style: TextStyle(
              color: isDestructive ? Colors.red[400] : const Color(0xFF06370b),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontVariations: [FontVariation('wght', 400)],
              fontFamily: 'Montserrat',
            ),
          ),
          trailing: isDestructive
              ? null
              : Icon(Icons.chevron_right, color: Colors.grey[400]),
          onTap: onTap,
        ),
        const Divider(
          height: 1,
          thickness: 1,
          indent: 20,
          endIndent: 20,
        ),
      ],
    );
  }
}
