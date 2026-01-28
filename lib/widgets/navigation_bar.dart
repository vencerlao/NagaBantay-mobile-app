import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../pages/home_page.dart';
import '../pages/category-report_page.dart';
import '../pages/alerts_page.dart';
import '../pages/account_page.dart';

class NagabantayNavBar extends StatefulWidget {
  const NagabantayNavBar({super.key});

  @override
  State<NagabantayNavBar> createState() => _NagabantayNavBarState();
}

class _NagabantayNavBarState extends State<NagabantayNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ReportPage(),
    AlertsPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: SizedBox(
        height: 80, // adjust (72–88 is a good range)
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFDBF5D7),
          selectedItemColor: const Color(0xFF255E1F),
          unselectedItemColor: const Color(0xFF737373),

          iconSize: 22,

          selectedLabelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontVariations: [
              FontVariation('wght', 700),
            ],
          ),

          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontVariations: [
              FontVariation('wght', 700),
            ],
          ),

          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },

          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(PhosphorIcons.houseFill),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(PhosphorIcons.pencilSimpleLineFill),
              ),
              label: 'Report',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(PhosphorIcons.warningFill),
              ),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(PhosphorIcons.userFill),
              ),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
