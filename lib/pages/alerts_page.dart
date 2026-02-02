import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nagabantay_mobile_app/services/local_auth_store.dart';

class AlertsPage extends StatefulWidget {
  final int initialIndex;
  const AlertsPage({super.key, this.initialIndex = 0});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
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

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadUserBarangay();
  }

  String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  }

  String _normalizeBarangay(String raw) {
    return raw.trim().toLowerCase();
  }

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

  // Filter button used in the Information tab
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

              if (alerts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _infoFilter == 'MY' ? 'No current alerts in your area' : 'No alerts available',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Color(0xFF063B13),
                          fontVariations: const [FontVariation('wght', 400)],),
                    ),
                  ),
                );
              }

               // Build a simple list of alerts
               return ListView.separated(
                 padding: const EdgeInsets.symmetric(vertical: 8),
                 itemCount: alerts.length,
                 separatorBuilder: (_, __) => const SizedBox(height: 12),
                 itemBuilder: (context, index) {
                   final data = alerts[index];
                   final ts = data['createdAt'] as Timestamp?;
                   final d = ts?.toDate();

                   return GestureDetector(
                     onTap: () => _showAlertDetails(context, data),
                     child: Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(
                         color: unselectedBgColor,
                         borderRadius: BorderRadius.circular(14),
                         border: Border.all(color: headerTextColor, width: 1.2),
                       ),
                       child: Row(
                         children: [
                           const Icon(Icons.warning_rounded, size: 36, color: headerTextColor),
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
                                     color: headerTextColor,
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
                                     color: headerTextColor,
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
                 },
               );
             },
           ),
         ),
       ],
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

  void _showAlertDetails(BuildContext context, Map<String, dynamic> data) {
    final ts = data['createdAt'] as Timestamp?;
    final d = ts?.toDate();
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
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              Text(data['subject'] ?? 'Alert', style: const TextStyle(fontSize: 22, fontVariations: [FontVariation('wght', 600)], color: headerTextColor, fontFamily: 'Montserrat')),
              const Divider(height: 30),
              Text('From: ${data['from'] ?? 'Unknown'}', style: const TextStyle( fontVariations: [FontVariation('wght', 400)], color: headerTextColor, fontSize: 14)),
              Text('Date: ${d != null ? '${_getMonthName(d.month)} ${d.day}, ${d.year}' : '-'}', style: const TextStyle( fontVariations: [FontVariation('wght', 400)], color: headerTextColor, fontSize: 13)),
              const SizedBox(height: 20),
              Text(data['message'] ?? 'No message content provided.', style: const TextStyle(fontSize: 16, height: 1.5, fontFamily: 'Montserrat', fontVariations: [FontVariation('wght', 600)], color: headerTextColor)),
            ],
          ),
        ),
      ),
    );
  }


  Widget _baseSafetyContainer({
    required IconData icon,
    required String title,
    required List<String> bullets,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: const Color(0xFF23552C)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w700, color: headerTextColor)),
                const SizedBox(height: 8),
                ...bullets.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 6), child: Icon(Icons.circle, size: 5, color: headerTextColor)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: headerTextColor))),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typhoonSafetyContainer() => _baseSafetyContainer(icon: Icons.cloud, title: 'Typhoon', bullets: ['Stay Indoors', 'Secure Items', 'Prepare Emergency Kit', 'Monitor Alerts', 'Evacuate if necessary'], bgColor: unselectedBgColor);
  Widget _earthquakeSafetyContainer() => _baseSafetyContainer(icon: Icons.terrain, title: 'Earthquake', bullets: ['Drop, Cover, Hold', 'Stay Away from Glass', 'Move to Open Area', 'Don’t Rush Outside'], bgColor: unselectedBgColor);
  Widget _fireSafetyContainer() => _baseSafetyContainer(icon: Icons.local_fire_department, title: 'Fire', bullets: ['Crawl Low', 'Get Out, Stay Out', 'Check Doors', 'Use Stairs when going Outside'], bgColor: unselectedBgColor);
}