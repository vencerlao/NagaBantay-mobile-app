import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../pages/home_page.dart';
import '../pages/category-report_page.dart';
import '../pages/alerts_page.dart';
import '../pages/account_page.dart';

class NagabantayNavBar extends StatefulWidget {
  final int initialIndex;
  final String phoneNumber;

  const NagabantayNavBar({
    super.key,
    this.initialIndex = 0,
    required this.phoneNumber,
  });

  @override
  State<NagabantayNavBar> createState() => _NagabantayNavBarState();
}

class _NagabantayNavBarState extends State<NagabantayNavBar> {
  late int _currentIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 3);

    // Initialize pages here so we can use widget.phoneNumber
    _pages = [
      HomePage(phoneNumber: widget.phoneNumber),
      ReportPage(phoneNumber: widget.phoneNumber),
      const AlertsPage(),
      const AccountPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const Color navBgColor = Color(0xFFDBF5D7);
    const Color activeColor = Color(0xFF255E1F);
    const Color inactiveColor = Color(0xFF737373);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: navBgColor,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: navBgColor,
          selectedItemColor: activeColor,
          unselectedItemColor: inactiveColor,
          iconSize: 24,
          elevation: 8,
          landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.houseFill),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.pencilSimpleLineFill),
              label: 'Report',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.warningFill),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.userFill),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}