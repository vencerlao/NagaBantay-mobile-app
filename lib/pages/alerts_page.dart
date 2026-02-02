import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AlertsPage extends StatefulWidget {
  final int initialIndex;
  const AlertsPage({super.key, this.initialIndex = 0});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  late int _selectedIndex;

  static const Color headerTextColor = Color(0xFF0F4A17);

  static const Color selectedBgColor = Color(0xFF0F4A17);
  static const Color unselectedBgColor = Color(0xffe6efe5);

  static const Color selectedTextColor = Colors.white;
  static const Color unselectedTextColor = Color(0xFF0F4A17);

  static const Color selectedBorderColor = Color(0xFF0F4A17);
  static const Color unselectedBorderColor = Color(0xFFB7D1BB);

  static const double selectedBorderWidth = 1.5;
  static const double unselectedBorderWidth = 1.2;

  static const Color infoContainerOneBg = Color(0xFFEAF4EA);
  static const Color infoContainerTwoBg = Color(0xFFF3F8F3);

  static const Color safetyContainerOneBg = infoContainerOneBg;
  static const Color safetyContainerTwoBg = infoContainerTwoBg;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 48,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: [
              const Text(
                'Alerts',
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Montserrat',
                  color: headerTextColor,
                  fontVariations: [FontVariation('wght', 700)],
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _segmentButton('Information', 0),
                  const SizedBox(width: 10),
                  _segmentButton('Safety Guides', 1),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    _buildInformationContent(),
                    _buildSafetyGuidesContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _segmentButton(String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : unselectedBgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? selectedBorderColor : unselectedBorderColor,
            width: isSelected ? selectedBorderWidth : unselectedBorderWidth,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: isSelected ? selectedTextColor : unselectedTextColor,
            fontVariations: [
              FontVariation('wght', isSelected ? 700 : 400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformationContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _infoContainerOne(),
          const SizedBox(height: 30),
          _infoContainerTwo(),
        ],
      ),
    );
  }

  Widget _infoContainerOne() {
    return _baseInfoContainer(
      image: 'assets/images/typhoon.png',
      title: 'Weather Advisory: Typhoon ADA',
      date: 'January 17, 2026',
      bgColor: infoContainerOneBg,
    );
  }

  Widget _infoContainerTwo() {
    return _baseInfoContainer(
      image: 'assets/images/earthquake.png',
      title: 'Natural Calamity: Magnitude 5.8 Earthquake',
      date: 'January 17, 2026',
      bgColor: infoContainerTwoBg,
    );
  }

  Widget _baseInfoContainer({
    required String image,
    required String title,
    required String date,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: unselectedBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              image,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'NEWS',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              fontVariations: [FontVariation('wght', 400)],
              color: Color(0xFF0F4A17),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontVariations: [FontVariation('wght', 600)],
              color: Color(0xFF0F4A17),
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              fontVariations: [FontVariation('wght', 400)],
              color: Color(0xFF0F4A17),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyGuidesContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _typhoonSafetyContainer(),
          const SizedBox(height: 12),
          _earthquakeSafetyContainer(),
          const SizedBox(height: 12),
          _fireSafetyContainer(),
        ],
      ),
    );
  }

  Widget _typhoonSafetyContainer() {
    return _baseSafetyContainer(
      icon:  PhosphorIcons.cloudRainFill,
      title: 'Typhoon',
      bullets: [
        'Stay Indoors',
        'Secure Items',
        'Prepare Emergency Kit',
        'Monitor Alerts',
        'Evacuate if necessary',
      ],
      bgColor: safetyContainerOneBg,
    );
  }

  Widget _earthquakeSafetyContainer() {
    return _baseSafetyContainer(
      icon: Icons.terrain,
      title: 'Earthquake',
      bullets: [
        'Drop, Cover, Hold',
        'Stay Away from Glass',
        'Move to Open Area',
        'Don’t Rush Outside',
      ],
      bgColor: safetyContainerTwoBg,
    );
  }

  Widget _fireSafetyContainer() {
    return _baseSafetyContainer(
      icon: Icons.local_fire_department,
      title: 'Fire',
      bullets: [
        'Crawl Low',
        'Get Out, Stay Out',
        'Check Doors',
        'Use Stairs when going Outside',
      ],
      bgColor: safetyContainerOneBg,
    );
  }

  Widget _baseSafetyContainer({
    required IconData icon,
    required String title,
    required List<String> bullets,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: unselectedBorderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 42, color: const Color(0xFF23552C)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontVariations: [FontVariation('wght', 600)],
                    color: Color(0xFF0F4A17),
                  ),
                ),
                const SizedBox(height: 8),
                ...bullets.map(
                      (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.circle,
                            size: 6, color: Color(0xFF0F4A17)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            e,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontVariations: [
                                FontVariation('wght', 400)
                              ],
                              color: Color(0xFF0F4A17),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
