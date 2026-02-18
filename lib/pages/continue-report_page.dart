import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:nagabantay_mobile_app/pages/changepin_page.dart';
import 'package:nagabantay_mobile_app/widgets/navigation_bar.dart';
import '../services/tflite_service.dart';
import '../models/report_draft.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

User? _currentUser;
File? _pickedImage;


final ImagePicker _picker = ImagePicker();

class ReportContinuePage extends StatefulWidget {
  final ReportDraft draft;
  final String phoneNumber;
  const ReportContinuePage({super.key, required this.draft, required this.phoneNumber,});

  @override
  State<ReportContinuePage> createState() => _ReportContinuePageState();
}

class _ReportContinuePageState extends State<ReportContinuePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final MapController _mapController = MapController();

  String? _barangay;
  LatLng? _selectedLocation;
  String _address = 'Fetching address...';

  bool _authChecked = false;


  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                PhosphorIcons.checkCircleFill,
                color: Color(0xFF39A736),
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Report Submitted!',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontVariations: [FontVariation('wght', 600)],
                  color: Color(0xFF23552C),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your report has been successfully submitted. Thank you for helping keep the community safe.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontVariations: [FontVariation('wght', 400)],
                  color: Color(0xFF23552C),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23552C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => NagabantayNavBar(
                      initialIndex: 0,
                      phoneNumber: widget.phoneNumber,
                    ),
                  ),
                      (route) => false,
                );
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontVariations: [FontVariation('wght', 500)],
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
        _authChecked = true;
      });
    });

    _descriptionController.text = widget.draft.description ?? '';
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _address = 'Location services are disabled';
          _selectedLocation = LatLng(13.6218, 123.1948);
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _address = 'Location permission denied';
          _selectedLocation = LatLng(13.6218, 123.1948);
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _selectedLocation =
            LatLng(position.latitude, position.longitude);
      });

      await _getAddressFromLatLng(_selectedLocation!);

    } catch (e) {
      print("Location error: $e");
      setState(() {
        _address = 'Unable to fetch location';
        _selectedLocation = LatLng(13.6218, 123.1948);
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Image conversion failed: $e');
      return null;
    }
  }


  Future<void> _getAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(location.latitude, location.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _barangay =
              place.subLocality ??
                  place.locality ??
                  place.subAdministrativeArea ??
                  'Unknown Barangay';

          _address =
          '${_barangay ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
        });
      } else {
        setState(() {
          _address = 'Unknown location';
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Error fetching address';
      });
    }
  }

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
      body: _selectedLocation == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose location',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontVariations: [FontVariation('wght', 500)],
                  color: Color(0xFF23552C),
                ),
              ),
              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: FlutterMap(
                        options: MapOptions(
                          center: _selectedLocation!,
                          zoom: 16,
                          minZoom: 10,
                          maxZoom: 18,
                          interactiveFlags: InteractiveFlag.all,
                          onTap: (tapPosition, point) {
                            setState(() {
                              _selectedLocation = point;
                            });
                            _getAddressFromLatLng(point);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                            userAgentPackageName: 'com.adjust.nagabantay',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _selectedLocation!,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  PhosphorIcons.mapPinFill,
                                  size: 32,
                                  color: Color(0xFF39A736),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    ),

                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChangePinPage()),
                          );

                          if (result != null) {
                            final loc = result['location'] as LatLng?;
                            final addr = result['address'] as String?;
                            if (loc != null && addr != null) {
                              setState(() {
                                _selectedLocation = loc;
                                _address = addr;
                              });
                              _mapController.move(_selectedLocation!, 16);
                            }
                          }
                        },

                        icon: const Icon(
                          PhosphorIcons.mapPinFill,
                          size: 18.0,
                          color: Color(0xff06370b),
                        ),
                        label: const Text(
                          'Change Pin',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            fontVariations: [FontVariation('wght', 400)],
                            color: Color(0xFF23552C),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(
                    PhosphorIcons.mapPinFill,
                    size: 18,
                    color: Color(0xff06370b),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _address,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontVariations: [FontVariation('wght', 400)],
                        color: Color(0xFF23552C),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                'Tell us what happened',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontVariations: [FontVariation('wght', 500)],
                  color: Color(0xFF23552C),
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                onChanged: (value) {
                  widget.draft.description = value;
                },
                decoration: InputDecoration(
                  hintText: 'Describe the incident in detail...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontVariations: [FontVariation('wght', 400)],
                    color: Color(0xFF23552C),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF23552C),
                      width: 1.2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF23552C),
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF06370B),
                      width: 1.6,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.6,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'Attach photos or videos (optional)',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontVariations: [FontVariation('wght', 500)],
                  color: Color(0xFF23552C),
                ),
              ),
              const SizedBox(height: 8),

              DottedBorder(
                color: const Color(0xFF23552C),
                strokeWidth: 1,
                dashPattern: const [6, 4],
                borderType: BorderType.RRect,
                radius: const Radius.circular(8),
                child: InkWell(
                  onTap: () async {
                    await _pickImage();
                  },

                  child: SizedBox(
                    width: double.infinity,
                    height: 120,
                    child: _pickedImage != null
                        ? Image.file(
                      _pickedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          PhosphorIcons.fileImage,
                          size: 32.0,
                          color: Color(0xff06370b),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to upload',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontVariations: const [FontVariation('wght', 400)],
                            color: const Color(0xFF23552C).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      final phoneNumber = widget.phoneNumber;

                      final description = _descriptionController.text.trim();
                      final loc = _selectedLocation;

                      if (description.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please provide a description')),
                        );
                        return;
                      }

                      if (loc == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location not selected')),
                        );
                        return;
                      }

                      widget.draft
                        ..description = description
                        ..latitude = loc.latitude
                        ..longitude = loc.longitude;

                      try {
                        final reportsRef =
                        FirebaseFirestore.instance.collection('reports');

                        final querySnapshot = await reportsRef.get();

                        int maxNumber = 0;
                        for (var doc in querySnapshot.docs) {
                          final number = int.tryParse(doc.id.replaceAll(RegExp(r'[^0-9]'), ''));
                          if (number != null && number > maxNumber) maxNumber = number;
                        }

                        final nextId = 'R${(maxNumber + 1).toString().padLeft(3, '0')}';

                        final docRef = FirebaseFirestore.instance.collection('reports').doc(nextId);

                        String? imageBase64;
                        if (_pickedImage != null) {
                          imageBase64 = await _convertImageToBase64(_pickedImage!);
                        }

                        await docRef.set({
                          'report_id': nextId,
                          'issue': widget.draft.issue ?? 'Unknown',
                          'description': description,
                          'barangay': _address,
                          'latitude': loc.latitude,
                          'longitude': loc.longitude,
                          'location': GeoPoint(loc.latitude, loc.longitude),
                          'image_attachments': imageBase64 != null ? [imageBase64] : [],
                          'my_naga_status': 'not yet responded',
                          'phone': phoneNumber,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        _showSuccessDialog();

                        try {
                          final tfliteService = TFLiteService();
                          await tfliteService.loadModel();
                          final modelOutput = await tfliteService.predict(description);

                          final severityLabel = modelOutput['severity'] ?? 'Unknown';
                          final severityConfidence = modelOutput['severity_confidence'] ?? 0.0;
                          final officeLabel = modelOutput['office'] ?? 'Unknown';
                          final officeConfidence = modelOutput['office_confidence'] ?? 0.0;

                          await docRef.update({
                            'predicted_severity': severityLabel,
                            'severity_confidence': severityConfidence,
                            'office': officeLabel,
                            'office_confidence': officeConfidence,
                          });

                          print('AI labels saved successfully');
                        } catch (e, s) {
                          print('TFLite prediction failed: $e');
                          print(s);
                        }

                      } catch (e) {
                        print('Firestore write failed: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to submit report: $e')),
                        );
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Submit Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
