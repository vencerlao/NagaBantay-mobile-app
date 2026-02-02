import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:nagabantay_mobile_app/pages/hazardmap_page.dart';
import 'package:nagabantay_mobile_app/services/flood_map_service.dart';
import 'package:nagabantay_mobile_app/services/local_auth_store.dart';

class HomePage extends StatelessWidget {
  final String phoneNumber;

  const HomePage({super.key, required this.phoneNumber});

  static const Color primaryGreen = Color(0xFF06370B);
  static const Color borderGreen = Color(0xFF669062);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildReportStatusSection(context),
                const SizedBox(height: 26),
                _buildMapHeader(context),
                const SizedBox(height: 10),
                const MapOverviewCard(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Image.asset(
          'assets/images/nagabantay_header.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _userDocStream(),
            builder: (context, snapshot) {
              String firstName = '';

              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() ?? <String, dynamic>{};
                firstName = (data['firstName'] ?? '').toString().trim();
              }

              return Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Marhay na Aldaw,\n',
                      style: TextStyle(
                        fontVariations: [FontVariation('wght', 500)],
                      ),
                    ),
                    TextSpan(
                      text: firstName.isNotEmpty ? '$firstName!' : 'User!',
                      style: const TextStyle(
                        fontVariations: [FontVariation('wght', 700)],
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  height: 1.1,
                  color: HomePage.primaryGreen,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report Status',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 22,
            fontVariations: [FontVariation('wght', 700)],
            color: primaryGreen,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _bigStatusCard(
                icon: PhosphorIcons.checkCircleFill,
                label: 'Completed',
                count: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _bigStatusCard(
                icon: PhosphorIcons.starFill,
                label: 'Ratings',
                count: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusButtons() {
    return Row(
      children: [
        _smallStatusChip(PhosphorIcons.fileTextFill, 'Submitted', 0, primaryGreen),
        const SizedBox(width: 8),
        _smallStatusChip(PhosphorIcons.hourglassFill, 'Pending', 0, primaryGreen),
        const SizedBox(width: 8),
        _smallStatusChip(PhosphorIcons.xCircleFill, 'Cancelled', 0, primaryGreen),
      ],
    );
  }

  Widget _smallStatusChip(IconData icon, String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Color(0xFF669062), width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 22,
                  fontVariations: [FontVariation('wght', 700)],
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _bigStatusCard(icon: PhosphorIcons.checkCircleFill, label: 'Completed', count: 0)),
                  const SizedBox(width: 12),
                  Expanded(child: _bigStatusCard(icon: PhosphorIcons.starFill, label: 'Ratings', count: 0)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _smallStatusChip(
                    context,
                    PhosphorIcons.fileTextFill,
                    'Submitted',
                    0,
                    primaryGreen,
                    statusFilter: 'not yet responded',
                  ),
                  const SizedBox(width: 8),
                  _smallStatusChip(
                    context,
                    PhosphorIcons.hourglassFill,
                    'Pending',
                    0,
                    primaryGreen,
                    statusFilter: 'pending',
                  ),
                  const SizedBox(width: 8),
                  _smallStatusChip(
                    context,
                    PhosphorIcons.xCircleFill,
                    'Cancelled',
                    0,
                    primaryGreen,
                    statusFilter: 'cancelled',
                  ),
                ],
              ),
            ],
          );
        }

        final reportsQuery = FirebaseFirestore.instance
            .collection('reports')
            .where('phone', isEqualTo: userPhoneId);

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: reportsQuery.snapshots(),
          builder: (context, reportsSnapshot) {
            int completed = 0;
            int ratings = 0;
            int submitted = 0;
            int pending = 0;
            int cancelled = 0;

            if (reportsSnapshot.hasData) {
              for (final doc in reportsSnapshot.data!.docs) {
                final data = doc.data();
                final status = (data['my_naga_status'] ?? '').toString().trim().toLowerCase();

                if (status == 'done' || status == 'completed') {
                  completed++;
                } else if (status == 'awaiting review' || status == 'awaiting_review') {
                  ratings++;
                } else if (status == 'not yet responded' || status == 'not_yet_responded') {
                  submitted++;
                } else if (status == 'pending') {
                  pending++;
                } else if (status == 'cancelled' || status == 'canceled') {
                  cancelled++;
                }
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Report Status',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 22,
                    fontVariations: [FontVariation('wght', 700)],
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportsListPage(
                                title: 'Completed',
                                userPhone: userPhoneId,
                                statusFilter: 'done',
                              ),
                            ),
                          );
                        },
                        child: _bigStatusCard(
                          icon: PhosphorIcons.checkCircleFill,
                          label: 'Completed',
                          count: completed,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportsListPage(
                                title: 'Ratings',
                                userPhone: userPhoneId,
                                statusFilter: 'awaiting review',
                              ),
                            ),
                          );
                        },
                        child: _bigStatusCard(
                          icon: PhosphorIcons.starFill,
                          label: 'Ratings',
                          count: ratings,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _smallStatusChip(
                      context,
                      PhosphorIcons.fileTextFill,
                      'Submitted',
                      submitted,
                      primaryGreen,
                      statusFilter: 'not yet responded',
                      userPhone: userPhoneId,
                    ),
                    const SizedBox(width: 8),
                    _smallStatusChip(
                      context,
                      PhosphorIcons.hourglassFill,
                      'Pending',
                      pending,
                      primaryGreen,
                      statusFilter: 'pending',
                      userPhone: userPhoneId,
                    ),
                    const SizedBox(width: 8),
                    _smallStatusChip(
                      context,
                      PhosphorIcons.xCircleFill,
                      'Cancelled',
                      cancelled,
                      primaryGreen,
                      statusFilter: 'cancelled',
                      userPhone: userPhoneId,
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMapHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Map Overview',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontVariations: [FontVariation('wght', 700)],
            color: primaryGreen,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HazardMapPage()),
          ),
          child: const Text(
            'View Full Map >',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bigStatusCard({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: primaryGreen,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontVariations: const [FontVariation('wght', 700)],
              color: primaryGreen,
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontVariations: const [FontVariation('wght', 800)],
              color: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallStatusChip(BuildContext context, IconData icon, String label, int count, Color color, {String? statusFilter, String? userPhone}) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          String docId = userPhone ?? '';
          if (docId.isEmpty) {
            final u = FirebaseAuth.instance.currentUser;
            if (u != null && u.phoneNumber != null) {
              docId = _normalizePhone(u.phoneNumber!);
            }
            if (docId.isEmpty) {
              final stored = LocalAuthStore.loggedPhone;
              if (stored != null && stored.isNotEmpty) {
                docId = _normalizePhone(stored);
              }
            }
          }

          if (docId.isEmpty) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportsListPage(
                title: label,
                userPhone: docId,
                statusFilter: statusFilter,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF669062), width: 2.0),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontVariations: const [FontVariation('wght', 700)],
                    fontSize: 11,
                    color: color,
                  ),
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  fontVariations: const [FontVariation('wght', 800)],
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderGreen, width: 2.0),
      boxShadow: [
        BoxShadow(
          color: const Color.fromRGBO(0, 0, 0, 0.02),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  String _normalizePhone(String raw) {
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly.length > 10 ? digitsOnly.substring(digitsOnly.length - 10) : digitsOnly;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userDocStream() {
    return FirebaseAuth.instance.authStateChanges().asyncExpand((user) {
      String? docId;

      if (user != null && user.phoneNumber != null) {
        docId = _normalizePhone(user.phoneNumber!);
        debugPrint('FINAL DOC ID USED (auth): $docId (from ${user.phoneNumber})');
      }

      if (docId == null) {
        final stored = LocalAuthStore.loggedPhone;
        if (stored != null && stored.isNotEmpty) {
          docId = _normalizePhone(stored);
          debugPrint(' FINAL DOC ID USED (local store): $docId');
        }
      }

      if (docId == null || docId.isEmpty) return const Stream.empty();

      return FirebaseFirestore.instance.collection('users').doc(docId).snapshots();
    });
  }
}

class MapOverviewCard extends StatelessWidget {
  const MapOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HazardMapPage()),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF669062), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: IgnorePointer(
              child: MapWidget(
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(123.2, 13.63)),
                  zoom: 12.0,
                  pitch: 0.0,
                ),
                styleUri: "mapbox://styles/mapbox/streets-v12",
                onMapCreated: (mapboxMap) async {
                  await FloodMapService.instance.loadFloodDataOnce();
                  await mapboxMap.style.addSource(GeoJsonSource(
                    id: "flood-source-preview",
                    data: FloodMapService.instance.geoJsonString!,
                  ));
                  await mapboxMap.style.addLayer(FillLayer(
                    id: "flood-layer-preview",
                    sourceId: "flood-source-preview",
                    fillColorExpression: [
                      "match",
                      ["get", "Var"],
                      1, "#FFFF00",
                      2, "#FFA500",
                      3, "#FF0000",
                      "#000000",
                    ],
                    fillOpacity: 0.35,
                  ));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReportsListPage extends StatelessWidget {
  final String title;
  final String userPhone;
  final String? statusFilter;

  const ReportsListPage({super.key, required this.title, required this.userPhone, this.statusFilter});

  Query<Map<String, dynamic>> _buildQuery() {
    return FirebaseFirestore.instance.collection('reports').where('phone', isEqualTo: userPhone);
  }

  String _formatTimestamp(dynamic ts) {
    try {
      DateTime d;
      if (ts == null) return '-';
      if (ts is Timestamp) d = ts.toDate();
      else if (ts is DateTime) d = ts;
      else if (ts is int) d = DateTime.fromMillisecondsSinceEpoch(ts);
      else return ts.toString();

      final local = d.toLocal();
      final month = local.month.toString().padLeft(2, '0');
      final day = local.day.toString().padLeft(2, '0');
      final year = local.year.toString();
      final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
      final minute = local.minute.toString().padLeft(2, '0');
      final ampm = local.hour >= 12 ? 'PM' : 'AM';
      return '$month/$day/$year $hour:$minute $ampm';
    } catch (e) {
      return ts.toString();
    }
  }

  dynamic _extractTimestamp(Map<String, dynamic> data) {
    for (final key in ['createdAt', 'timestamp', 'date_created', 'dateCreated', 'time_created']) {
      if (data.containsKey(key) && data[key] != null) return data[key];
    }
    return null;
  }

  String _safeString(Map<String, dynamic> data, List<String> keys, [String fallback = '']) {
    for (final k in keys) {
      final v = data[k];
      if (v != null) return v.toString();
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final query = _buildQuery();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: HomePage.primaryGreen,
            fontFamily: 'Montserrat',
            fontVariations: [FontVariation('wght', 700)],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: HomePage.primaryGreen,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snapshot.data!.docs;
          if (statusFilter != null) {
            final norm = statusFilter!.toString().trim().toLowerCase();
            docs = docs.where((d) {
              final s = (d.data()['my_naga_status'] ?? '').toString().trim().toLowerCase();
              return s == norm;
            }).toList();
          }

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No reports found',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Color(0xFF063B13),
                  fontVariations: [
                    FontVariation('wght', 400),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final issue = _safeString(data, ['issue', 'category', 'title'], 'Issue');
              final description = _safeString(data, ['description', 'desc', 'details'], '');
              final severity = _safeString(data, ['severity', 'priority'], 'N/A');
              final ts = _extractTimestamp(data);
              final timeStr = _formatTimestamp(ts);

              return GestureDetector(
                onTap: () {
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE6E6E6)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 60,
                        margin: const EdgeInsets.only(right: 12, top: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(severity),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Issue (title)
                            Text(
                              issue,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                fontVariations: [FontVariation('wght', 800)],
                                color: Color(0xFF163A18),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              description,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Color(0xFF163A18),
                                fontVariations: [FontVariation('wght', 500)],
                                height: 1.35,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 10),

                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 6,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _statusColor(severity).withAlpha((0.08 * 255).round()),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    severity.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _statusColor(severity),
                                      fontVariations: const [FontVariation('wght', 700)],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    timeStr,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontVariations: const [FontVariation('wght', 400)],
                                        color: Colors.black54),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _statusColor(String severity) {
    final s = severity.toLowerCase();
    if (s.contains('high') || s.contains('critical') || s.contains('severe')) return Colors.red.shade700;
    if (s.contains('medium') || s.contains('moderate')) return Colors.orange.shade700;
    if (s.contains('low') || s.contains('minor')) return Colors.green.shade700;
    return Colors.grey.shade600;
  }
}
