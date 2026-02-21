import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nagabantay_mobile_app/services/local_auth_store.dart';
import 'package:audioplayers/audioplayers.dart';

class AlertsPage extends StatefulWidget {
  final int initialIndex;
  const AlertsPage({super.key, this.initialIndex = 0});
  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

Map<String, Set<String>> _existingAlertIdsByFilter = {
  'MY': {},
  'ALL': {},
};

class _SafetyGuide {
  final IconData icon;
  final String title;
  final String goal;
  final List<String> guides;
  final Color accentColor;
  const _SafetyGuide({
    required this.icon,
    required this.title,
    required this.goal,
    required this.guides,
    this.accentColor = const Color(0xFF0F4A17),
  });
}

_SafetyGuide? _getSafetyGuide(String? subject) {
  if (subject == null) return null;
  final normalized = subject.trim().toUpperCase();

  if (normalized.contains('FLOOD')) {
    return const _SafetyGuide(
      icon: Icons.water,
      title: 'Flood Alert',
      goal: 'Protect residents from rising water and reduce injury or property damage.',
      accentColor: Color(0xFF1565C0),
      guides: [
        'Prepare an emergency go-bag (water, food, flashlight, medicine, documents).',
        'Move appliances and valuables to higher areas.',
        'Avoid walking or driving through floodwaters.',
        'Turn off electricity if water starts entering the house.',
        'Monitor barangay announcements and evacuation notices.',
        'Keep phones fully charged.',
        'Prepare to evacuate immediately if water levels rise quickly.',
        'Keep children and elderly away from flooded areas.',
      ],
    );
  }

  if (normalized.contains('TYPHOON')) {
    return const _SafetyGuide(
      icon: Icons.air,
      title: 'Typhoon Warning',
      goal: 'Minimize risks from strong winds and heavy rainfall.',
      accentColor: Color(0xFF37474F),
      guides: [
        'Secure windows, roofs, and loose outdoor objects.',
        'Charge mobile phones and power banks.',
        'Store clean drinking water and ready-to-eat food.',
        'Prepare flashlights and extra batteries.',
        'Avoid unnecessary travel during strong winds.',
        'Identify the nearest evacuation center.',
        'Stay indoors and away from windows.',
        'Follow official LGU and barangay advisories.',
      ],
    );
  }

  if (normalized.contains('HEAT')) {
    return const _SafetyGuide(
      icon: Icons.wb_sunny,
      title: 'Extreme Heat',
      goal: 'Prevent heat exhaustion and heatstroke.',
      accentColor: Color(0xFFE65100),
      guides: [
        'Drink water frequently even if not thirsty.',
        'Avoid outdoor activities during peak heat hours (10 AM – 4 PM).',
        'Wear light-colored, loose clothing.',
        'Stay in shaded or well-ventilated areas.',
        'Check on elderly, children, and vulnerable neighbors.',
        'Never leave children or pets inside parked vehicles.',
        'Watch for signs of heat exhaustion (dizziness, nausea, weakness).',
        'Seek medical help if symptoms worsen.',
      ],
    );
  }

  if (normalized.contains('FIRE')) {
    return const _SafetyGuide(
      icon: Icons.local_fire_department,
      title: 'Fire Incident',
      goal: 'Ensure safe evacuation and prevent fire spread.',
      accentColor: Color(0xFFC62828),
      guides: [
        'Evacuate immediately if instructed by authorities.',
        'Stay away from the affected area.',
        'Turn off gas tanks and electrical appliances if safe to do so.',
        'Cover nose and mouth with cloth to avoid smoke inhalation.',
        'Use stairs instead of elevators.',
        'Assist children, elderly, and persons with disabilities.',
        'Do not return home until authorities declare the area safe.',
        'Report trapped individuals to emergency responders immediately.',
      ],
    );
  }

  if (normalized.contains('WASTE') || normalized.contains('COLLECTION')) {
    return const _SafetyGuide(
      icon: Icons.delete_outline,
      title: 'Waste Collection Notice',
      goal: 'Prevent flooding and sanitation hazards caused by improper waste disposal.',
      accentColor: Color(0xFF2E7D32),
      guides: [
        'Dispose garbage only during scheduled collection times.',
        'Separate biodegradable and non-biodegradable waste.',
        'Tie garbage bags securely.',
        'Avoid placing trash near drainage canals.',
        'Flatten large boxes to reduce pile-ups.',
        'Keep sidewalks and streets clear after disposal.',
        'Report uncollected waste through the app.',
        'Store waste properly to prevent animals from scattering trash.',
      ],
    );
  }

  if (normalized.contains('DRAINAGE') || normalized.contains('CLOGGED')) {
    return const _SafetyGuide(
      icon: Icons.water_damage,
      title: 'Clogged Drainage Clearing',
      goal: 'Improve water flow and reduce flood risk.',
      accentColor: Color(0xFF0277BD),
      guides: [
        'Avoid parking near drainage or canal areas.',
        'Keep surroundings free from leaves and debris.',
        'Do not throw garbage into waterways.',
        'Keep children away from maintenance operations.',
        'Wear proper footwear when passing muddy areas.',
        'Expect temporary road obstructions.',
        'Report additional blocked drainage via the app.',
        'Prepare for possible rainfall following clearing operations.',
      ],
    );
  }

  if (normalized.contains('TREE') || normalized.contains('PRUNING')) {
    return const _SafetyGuide(
      icon: Icons.park,
      title: 'Tree Pruning Advisory',
      goal: 'Prevent injuries and reduce typhoon hazards from falling branches.',
      accentColor: Color(0xFF388E3C),
      guides: [
        'Avoid walking or staying under trees being pruned.',
        'Move vehicles away from pruning zones.',
        'Secure outdoor furniture and loose items.',
        'Follow temporary road or sidewalk closures.',
        'Keep pets indoors during operations.',
        'Stay alert for falling branches or debris.',
        'Report unstable or leaning trees to the barangay.',
        'Avoid the area during strong winds while pruning is ongoing.',
      ],
    );
  }

  return null;
}

class _AlertsPageState extends State<AlertsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Set<String> _existingAlertIds = {};

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  late int _selectedIndex;
  String? _userBarangay;
  String _infoFilter = 'MY';
  bool _loadingBarangay = true;

  static const Color headerTextColor = Color(0xFF0F4A17);
  static const Color selectedBgColor = Color(0xFF0F4A17);
  static const Color unselectedBgColor = Color(0xffe6efe5);
  static const Color selectedTextColor = Colors.white;
  static const Color unselectedTextColor = Color(0xFF0F4A17);
  static const Color borderColor = Color(0xFFB7D1BB);
  static const Color newAlertTextColor = Color(0xFF740A03);
  static const Color newAlertAccentColor = Color(0xFFC3110C);

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadUserBarangay();
  }

  void _playAlertSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/alert.mp3'));
    } catch (e) {
      debugPrint('Failed to play alert sound: $e');
    }
  }

  String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  }

  String _normalizeBarangay(String raw) => raw.trim().toLowerCase();

  Future<void> _loadUserBarangay() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? phone;
      if (user?.phoneNumber != null) {
        phone = _normalizePhone(user!.phoneNumber!);
      }
      phone ??= LocalAuthStore.loggedPhone;
      if (phone == null) {
        _loadingBarangay = false;
        if (mounted) setState(() {});
        return;
      }
      final doc = await FirebaseFirestore.instance.collection('users').doc(phone).get();
      if (doc.exists) {
        _userBarangay = _normalizeBarangay(doc.data()?['barangay']?.toString() ?? '');
      }
    } catch (e) {
      debugPrint('Barangay load error: $e');
    }
    _loadingBarangay = false;
    if (mounted) setState(() {});
  }

  Stream<List<Map<String, dynamic>>> _alertsStream() {
    return FirebaseFirestore.instance
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final allAlerts = snapshot.docs
          .map((doc) => Map<String, dynamic>.from(doc.data())..['id'] = doc.id)
          .toList();

      List<String> extractBarangays(Map<String, dynamic> alert) {
        final candidates = <String>['barangays', 'barangay', 'parangays', 'parangay'];
        for (final key in candidates) {
          final raw = alert[key];
          if (raw is List) {
            return raw.map((e) => _normalizeBarangay(e.toString())).toList();
          }
        }
        return <String>[];
      }

      final userBarangayKnown = _userBarangay != null && _userBarangay!.isNotEmpty;
      final normalizedUserBarangay = userBarangayKnown ? _normalizeBarangay(_userBarangay!) : null;

      return allAlerts.where((alert) {
        final arr = extractBarangays(alert);
        if (_infoFilter == 'MY') {
          if (!userBarangayKnown) return false;
          return arr.contains(normalizedUserBarangay);
        }
        if (userBarangayKnown) {
          return arr.contains(normalizedUserBarangay) || arr.contains('all');
        }
        return arr.contains('all');
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 48,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Text(
                'Alerts',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Montserrat',
                  color: headerTextColor,
                  fontVariations: [FontVariation('wght', 700)],
                ),
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _segmentButton('Information', 0),
                    const SizedBox(width: 10),
                    _segmentButton('Safety Guides', 1),
                  ],
                ),
              ),
              const SizedBox(height: 15),
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
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : unselectedBgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: isSelected ? selectedTextColor : unselectedTextColor,
            fontVariations: [FontVariation('wght', isSelected ? 700 : 400)],
          ),
        ),
      ),
    );
  }

  Widget _filterButton(String label, String filter) {
    final selected = _infoFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _infoFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? selectedBgColor : unselectedBgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: selected ? selectedTextColor : unselectedTextColor,
              fontVariations: [FontVariation('wght', selected ? 700 : 400)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInformationContent() {
    if (_loadingBarangay) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _filterButton('My Barangay', 'MY')),
            const SizedBox(width: 10),
            Expanded(child: _filterButton('All Areas', 'ALL')),
          ],
        ),
        const SizedBox(height: 15),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _alertsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) return const Center(child: Text('Unable to load alerts'));
              final alerts = snapshot.data ?? [];
              final now = DateTime.now();

              final newAlerts = alerts.where((a) {
                final ts = a['createdAt'] as Timestamp?;
                if (ts == null) return false;
                return now.difference(ts.toDate()).inHours <= 24;
              }).toList();

              final olderAlerts = alerts.where((a) {
                final ts = a['createdAt'] as Timestamp?;
                if (ts == null) return false;
                return now.difference(ts.toDate()).inHours > 24;
              }).toList();

              final filterKey = _infoFilter;
              final newAlertIds = alerts.map((a) => a['id'] as String).toSet();
              final newlyAddedAlerts = newAlertIds.difference(_existingAlertIdsByFilter[filterKey]!);
              if (newlyAddedAlerts.isNotEmpty) _playAlertSound();
              _existingAlertIdsByFilter[filterKey] = newAlertIds;

              if (alerts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _infoFilter == 'MY'
                          ? 'No current alerts in your area'
                          : 'No alerts available',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Color(0xFF063B13),
                        fontVariations: [FontVariation('wght', 400)],
                      ),
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  if (newAlerts.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'New Alerts',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          fontVariations: [FontVariation('wght', 700)],
                          color: headerTextColor,
                        ),
                      ),
                    ),
                    ...newAlerts.map((data) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _alertTile(data, isNew: true),
                    )),
                    const SizedBox(height: 12),
                  ],
                  if (olderAlerts.isNotEmpty) ...[
                    if (newAlerts.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Older Alerts',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            fontVariations: [FontVariation('wght', 700)],
                            color: headerTextColor,
                          ),
                        ),
                      ),
                    ...olderAlerts.map((data) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _alertTile(data),
                    )),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _alertTile(Map<String, dynamic> data, {bool isNew = false}) {
    final ts = data['createdAt'] as Timestamp?;
    final d = ts?.toDate();
    final Color bgColor = isNew ? const Color(0xFFFFE5E5) : unselectedBgColor;
    final Color borderClr = isNew ? newAlertAccentColor : headerTextColor;
    final Color iconClr = isNew ? newAlertAccentColor : headerTextColor;
    final Color textClr = isNew ? newAlertTextColor : headerTextColor;

    return GestureDetector(
      onTap: () => _showAlertDetails(context, data),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderClr, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_rounded, size: 36, color: iconClr),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['subject'] ?? 'Alert',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontVariations: const [FontVariation('wght', 600)],
                      color: iconClr,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data['from'] ?? ''} | ${d != null ? '${_getMonthName(d.month)} ${d.day}, ${d.year}' : '-'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontVariations: const [FontVariation('wght', 400)],
                      color: textClr,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 24, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  void _showAlertDetails(BuildContext context, Map<String, dynamic> data) {
    final ts = data['createdAt'] as Timestamp?;
    final d = ts?.toDate();
    final guide = _getSafetyGuide(data['subject'] as String?);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                data['subject'] ?? 'Alert',
                style: const TextStyle(
                  fontSize: 22,
                  fontVariations: [FontVariation('wght', 700)],
                  color: headerTextColor,
                  fontFamily: 'Montserrat',
                ),
              ),
              const Divider(height: 30),
              Text(
                'From: ${data['from'] ?? 'Unknown'}',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontVariations: [FontVariation('wght', 500)],
                  color: headerTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Date: ${d != null ? '${_getMonthName(d.month)} ${d.day}, ${d.year}' : '-'}',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontVariations: const [FontVariation('wght', 400)],
                  color: headerTextColor.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                data['message'] ?? 'No message content provided.',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  fontFamily: 'Montserrat',
                  fontVariations: [FontVariation('wght', 400)],
                  color: Color(0xFF1C3A21),
                ),
              ),

              if (guide != null) ...[
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: guide.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(guide.icon, size: 18, color: guide.accentColor),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Safety Guide',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 17,
                        fontVariations: [FontVariation('wght', 700)],
                        color: headerTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: guide.accentColor.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: guide.accentColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Icons.flag_outlined, size: 15, color: guide.accentColor),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          guide.goal,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            height: 1.5,
                            fontVariations: const [FontVariation('wght', 600)],
                            color: guide.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ...guide.guides.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: guide.accentColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11,
                              fontVariations: const [FontVariation('wght', 700)],
                              color: guide.accentColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            height: 1.55,
                            fontVariations: [FontVariation('wght', 600)],
                            color: Color(0xFF1C3A21),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyGuidesContent() {
    if (_loadingBarangay) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _alertsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final alerts = snapshot.data ?? [];
        final seenTitles = <String>{};
        final matchedGuides = <_SafetyGuide>[];

        for (final alert in alerts) {
          final guide = _getSafetyGuide(alert['subject'] as String?);
          if (guide != null && seenTitles.add(guide.title)) {
            matchedGuides.add(guide);
          }
        }

        final guidesToShow = matchedGuides.isNotEmpty ? matchedGuides : _defaultSafetyGuides;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (matchedGuides.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, size: 13, color: headerTextColor.withOpacity(0.6)),
                      const SizedBox(width: 5),
                      Text(
                        'Based on current alerts in your area',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontVariations: const [FontVariation('wght', 500)],
                          color: headerTextColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ...guidesToShow.map((guide) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _safetyGuideCard(guide),
              )),
            ],
          ),
        );
      },
    );
  }

  static const List<_SafetyGuide> _defaultSafetyGuides = [
    _SafetyGuide(
      icon: Icons.air,
      title: 'Typhoon Warning',
      goal: 'Minimize risks from strong winds and heavy rainfall.',
      accentColor: Color(0xFF37474F),
      guides: [
        'Secure windows, roofs, and loose outdoor objects.',
        'Charge mobile phones and power banks.',
        'Store clean drinking water and ready-to-eat food.',
        'Prepare flashlights and extra batteries.',
        'Avoid unnecessary travel during strong winds.',
        'Identify the nearest evacuation center.',
        'Stay indoors and away from windows.',
        'Follow official LGU and barangay advisories.',
      ],
    ),
    _SafetyGuide(
      icon: Icons.local_fire_department,
      title: 'Fire Incident',
      goal: 'Ensure safe evacuation and prevent fire spread.',
      accentColor: Color(0xFFC62828),
      guides: [
        'Evacuate immediately if instructed by authorities.',
        'Stay away from the affected area.',
        'Turn off gas tanks and electrical appliances if safe to do so.',
        'Cover nose and mouth with cloth to avoid smoke inhalation.',
        'Use stairs instead of elevators.',
        'Assist children, elderly, and persons with disabilities.',
        'Do not return home until authorities declare the area safe.',
        'Report trapped individuals to emergency responders immediately.',
      ],
    ),
    _SafetyGuide(
      icon: Icons.water,
      title: 'Flood Alert',
      goal: 'Protect residents from rising water and reduce injury or property damage.',
      accentColor: Color(0xFF1565C0),
      guides: [
        'Prepare an emergency go-bag (water, food, flashlight, medicine, documents).',
        'Move appliances and valuables to higher areas.',
        'Avoid walking or driving through floodwaters.',
        'Turn off electricity if water starts entering the house.',
        'Monitor barangay announcements and evacuation notices.',
        'Keep phones fully charged.',
        'Prepare to evacuate immediately if water levels rise quickly.',
        'Keep children and elderly away from flooded areas.',
      ],
    ),
  ];

  Widget _safetyGuideCard(_SafetyGuide guide) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: guide.accentColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: guide.accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(guide.icon, size: 20, color: guide.accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    guide.title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      fontVariations: const [FontVariation('wght', 700)],
                      color: guide.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              guide.goal,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                height: 1.5,
                fontVariations: const [FontVariation('wght', 600)],
                color: const Color(0xFF1C3A21).withOpacity(0.65),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 20, color: borderColor),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: guide.guides.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: guide.accentColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11,
                              fontVariations: const [FontVariation('wght', 700)],
                              color: guide.accentColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            height: 1.55,
                            fontVariations: [FontVariation('wght', 600)],
                            color: Color(0xFF1C3A21),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}