import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:nagabantay_mobile_app/services/flood_map_service.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String toTitleCase(String text) {
  return text.toLowerCase().split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}

class Barangay {
  final String name;
  final double lat;
  final double lng;

  Barangay(this.name, this.lat, this.lng);
}

final List<Barangay> nagaBarangays = [
  Barangay("Abella", 13.6235, 123.1799),
  Barangay("Bagumbayan Norte", 13.6333, 123.1856),
  Barangay("Bagumbayan Sur", 13.6325, 123.1866),
  Barangay("Balatas", 13.6305, 123.2068),
  Barangay("Calauag", 13.6293, 123.1970),
  Barangay("Cararayan", 13.6290, 123.2396),
  Barangay("Carolina", 13.6264, 123.2651),
  Barangay("Concepcion Pequeña", 13.6150, 123.2028),
  Barangay("Dayangdang", 13.6273, 123.1932),
  Barangay("Del Rosario", 13.6174, 123.2372),
  Barangay("Dinaga", 13.6215, 123.1854),
  Barangay("Igualdad Interior", 13.6220, 123.1803),
  Barangay("Lerma", 13.6222, 123.1876),
  Barangay("Liboton", 13.6376, 123.1902),
  Barangay("Mabolo", 13.6145, 123.1826),
  Barangay("Pacol", 13.6502, 123.2425),
  Barangay("Panicuason", 13.6628, 123.3183),
  Barangay("Peñafrancia", 13.6303, 123.1913),
  Barangay("Sabang", 13.6197, 123.1814),
  Barangay("San Felipe", 13.6415, 123.2041),
  Barangay("San Francisco", 13.6257, 123.1821),
  Barangay("San Isidro", 13.6329, 123.2699),
  Barangay("Santa Cruz", 13.6257, 123.1821),
  Barangay("Tabuco", 13.6179, 123.1834),
  Barangay("Tinago", 13.6257, 123.1908),
  Barangay("Triangulo", 13.6160, 123.1905),
];

class EvacuationCenter {
  final String barangay;
  final String name;
  final double lat;
  final double lng;

  EvacuationCenter({
    required this.barangay,
    required this.name,
    required this.lat,
    required this.lng,
  });
}

enum MapMode { Flood, Evacuation }

class HazardMapPage extends StatefulWidget {
  const HazardMapPage({super.key});

  @override
  State<HazardMapPage> createState() => _HazardMapPageState();
}

class _HazardMapPageState extends State<HazardMapPage> {
  MapMode currentMode = MapMode.Flood;

  late MapboxMap mapboxMap;
  Barangay? selectedBarangay;
  double? selectedFloodSeverity;
  final FloodMapService floodService = FloodMapService.instance;

  final mapboxApiKey = dotenv.env['MAPBOX_API_KEY'] ?? '';

  PointAnnotationManager? _pointAnnotationManager;
  List<PointAnnotation> evacPins = [];

  List<EvacuationCenter> evacuationCenters = [];
  EvacuationCenter? selectedCenter;

  @override
  void initState() {
    super.initState();
    loadEvacuationCenters().then((centers) {
      setState(() {
        evacuationCenters = centers;
      });
    });
  }

  double? _getFloodSeverityAtPoint(double lng, double lat) {
    for (var feature in floodService.floodPolygons) {
      final geometry = feature["geometry"];
      final properties = feature["properties"];

      if (geometry["type"] == "Polygon") {
        final coords = geometry["coordinates"];
        for (var polygon in coords) {
          if (_pointInPolygon(lng, lat, polygon)) {
            return properties["Var"]?.toDouble();
          }
        }
      } else if (geometry["type"] == "MultiPolygon") {
        final coords = geometry["coordinates"];
        for (var polySet in coords) {
          for (var polygon in polySet) {
            if (_pointInPolygon(lng, lat, polygon)) {
              return properties["Var"]?.toDouble();
            }
          }
        }
      }
    }
    return null;
  }

  bool _pointInPolygon(double x, double y, List coordinates) {
    int j = coordinates.length - 1;
    bool inside = false;

    for (int i = 0; i < coordinates.length; i++) {
      final xi = coordinates[i][0];
      final yi = coordinates[i][1];
      final xj = coordinates[j][0];
      final yj = coordinates[j][1];

      final intersect = ((yi > y) != (yj > y)) &&
          (x < (xj - xi) * (y - yi) / ((yj - yi) == 0 ? 0.00000001 : (yj - yi)) + xi);

      if (intersect) inside = !inside;
      j = i;
    }
    return inside;
  }


  Future<void> addPin(double lng, double lat, {String? label}) async {
    if (_pointAnnotationManager == null) return;

    await _pointAnnotationManager!.deleteAll();
    evacPins.clear();

    final options = PointAnnotationOptions(
      geometry: Point(coordinates: Position(lng, lat)),
      iconImage: "circle-duotone",
      iconSize: 0.5,
      textField: label ?? "",
      textSize: 14.0,
    );

    final pin = await _pointAnnotationManager!.create(options);
    evacPins.add(pin);
  }


  Future<List<dynamic>> loadEvacuationGeoJson() async {
    final String data = await rootBundle.loadString('assets/naga_evacuation1.geojson');
    final Map<String, dynamic> jsonData = jsonDecode(data);
    return jsonData['features'];
  }

  Future<List<EvacuationCenter>> loadEvacuationCenters() async {
    final features = await loadEvacuationGeoJson();

    return features.map<EvacuationCenter>((feature) {
      final props = feature['properties'];

      double lat = 0.0;
      double lng = 0.0;
      if (props['Latitude'] != null && props['Longitude'] != null) {
        lat = double.parse(props['Latitude'].toString());
        lng = double.parse(props['Longitude'].toString());
      }

      String name = (props['Evacuation'] ?? '').trim();

      return EvacuationCenter(
        barangay: (props['Barangay'] ?? '').trim(),
        name: name,
        lat: lat,
        lng: lng,
      );
    })
        .where((center) =>
    center.name.isNotEmpty &&
        !center.name.toUpperCase().contains("TOTAL") &&
        !center.name.toUpperCase().contains("N/A")
    )
        .toList();
  }

  Future<void> waitForStyleLoaded() async {
    while (!(await mapboxMap.style.isStyleLoaded())) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<Uint8List> iconToBytes(Icon icon) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.icon!.codePoint),
      style: TextStyle(
        fontSize: icon.size ?? 32.0,
        fontFamily: icon.icon!.fontFamily,
        package: icon.icon!.fontPackage,
        color: icon.color ?? Colors.black,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);

    final ui.Image img = await recorder.endRecording().toImage(
      (icon.size ?? 32.0).toInt(),
      (icon.size ?? 32.0).toInt(),
    );
    final ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> getMarkerIconBytes(Color color, double size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<void> addEvacuationIconToMap() async {
    final ByteData byteData =
    await rootBundle.load('assets/images/circle-duotone.png');

    final Uint8List bytes = byteData.buffer.asUint8List();

    final MbxImage image = MbxImage(
      width: 64,
      height: 64,
      data: bytes,
    );

    await mapboxMap.style.addStyleImage(
      'circle-duotone',
      1.0,
      image,
      false,
      [],
      [],
      null,
    );
  }

  Future<void> addEvacuationPinsFromGeoJson() async {
    if (_pointAnnotationManager == null) return;

    await _pointAnnotationManager!.deleteAll();
    evacPins.clear();

    final features = await loadEvacuationGeoJson();

    for (var feature in features) {
      final geometry = feature['geometry'];

      if (geometry['type'] == 'Point') {
        final coords = geometry['coordinates'];

        final options = PointAnnotationOptions(
          geometry: Point(coordinates: Position(coords[0], coords[1])),
          iconImage: "circle-duotone",
          iconSize: 0.3,
        );

        final pin = await _pointAnnotationManager!.create(options);
        evacPins.add(pin);
      }
    }
  }

  Future<void> addFloodLayer() async {
    try {
      await floodService.loadFloodDataOnce();
      await mapboxMap.style.addSource(
        GeoJsonSource(
          id: "flood-source",
          data: floodService.geoJsonString!,
        ),
      );
      await mapboxMap.style.addLayer(
        FillLayer(
          id: "flood-layer",
          sourceId: "flood-source",
          fillColorExpression: [
            "match",
            ["get", "Var"],
            1,
            "#FFFF00",
            2,
            "#FFA500",
            3,
            "#FF0000",
            "#000000"
          ],
          fillOpacity: 0.5,
        ),
      );
    } catch (e) {
      debugPrint("Error adding flood layer: $e");
    }
  }

  Future<void> removeEvacuationPins() async {
    if (_pointAnnotationManager == null) return;

    for (var pin in evacPins) {
      await _pointAnnotationManager!.delete(pin);
    }
    evacPins.clear();
  }

  Future<void> removeFloodLayer() async {
    try {
      final layers = await mapboxMap.style.getStyleLayers();
      if (layers.any((layer) => layer?.id == "flood-layer")) {
        await mapboxMap.style.removeStyleLayer("flood-layer");
      }

      final sources = await mapboxMap.style.getStyleSources();
      if (sources.any((source) => source?.id == "flood-source")) {
        await mapboxMap.style.removeStyleSource("flood-source");
      }
    } catch (e) {
      debugPrint("Error removing flood layer/source: $e");
    }
  }

  void goToBarangay(Barangay brgy) async {
    mapboxMap.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(brgy.lng, brgy.lat)),
        zoom: 16.0,
        pitch: 60.0,
        bearing: 30.0,
      ),
      null,
    );

    await addPin(brgy.lng, brgy.lat, label: brgy.name);

    if (floodService.floodPolygons.isNotEmpty) {
      selectedFloodSeverity = _getFloodSeverityAtPoint(brgy.lng, brgy.lat);
      setState(() {});

      String message;
      if (selectedFloodSeverity == 1) {
        message = "Flood Risk: Low";
      } else if (selectedFloodSeverity == 2) {
        message = "Flood Risk: Medium";
      } else if (selectedFloodSeverity == 3) {
        message = "Flood Risk: High";
      } else {
        message = "Flood Risk: Little to None";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontVariations: [FontVariation('wght', 500)],
                  color: Colors.white)),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          backgroundColor: selectedFloodSeverity == 1
              ? Colors.yellow
              : selectedFloodSeverity == 2
              ? Colors.orange
              : selectedFloodSeverity == 3
              ? Colors.red
              : Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 6,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            PhosphorIcons.caretLeft,
            size: 22.0,
            color: Color(0xff06370b),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          currentMode == MapMode.Flood ? "Flood Prone Areas" : "Evacuation Centers",
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontVariations: [FontVariation('wght', 500)],
            color: Color(0xFF23552C),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: currentMode == MapMode.Evacuation,
              onChanged: (val) async {
                setState(() {
                  currentMode = val ? MapMode.Evacuation : MapMode.Flood;
                });

                if (currentMode == MapMode.Flood) {
                  await removeEvacuationPins();
                  await addFloodLayer();
                } else {
                  await removeFloodLayer();
                  await addEvacuationPinsFromGeoJson();
                }
              },
              activeColor: Colors.green,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: currentMode == MapMode.Flood
                      ? DropdownSearch<Barangay>(
                    items: nagaBarangays,
                    selectedItem: selectedBarangay,
                    itemAsString: (brgy) => brgy.name,

                    onChanged: (item) {
                      if (item != null) {
                        setState(() => selectedBarangay = item);
                        goToBarangay(item);
                      }
                    },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: "Select Barangay",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                    ),

                    dropdownBuilder: (context, selectedItem) {
                      if (selectedItem == null) {
                        return Text(
                          "Select Barangay",
                          style: TextStyle(color: const Color(0xFF23552C).withOpacity(0.5),
                          ),
                        );
                      }
                      return Text(
                        selectedItem.name,
                        style: TextStyle(
                          color: Color(0xFF23552C),
                          fontVariations: [
                            FontVariation('wght', 450),
                          ],
                          fontSize: 16,
                        ),
                      );
                    },

                    popupProps: PopupProps.menu(
                      constraints: const BoxConstraints(maxHeight: 200),
                      itemBuilder: (context, brgy, isSelected) {
                        return Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(
                            brgy.name,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              color: Color(0xFF23552C),
                              fontVariations: [
                                FontVariation('wght', 400),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                      : DropdownSearch<EvacuationCenter>(
                    items: evacuationCenters,
                    selectedItem: selectedCenter,
                    itemAsString: (center) =>
                    "${toTitleCase(center.barangay)} - ${toTitleCase(center.name)}",
                    onChanged: (center) async {
                      if (center != null) {
                        setState(() => selectedCenter = center);
                        mapboxMap.flyTo(
                          CameraOptions(
                            center: Point(coordinates: Position(center.lng, center.lat)),
                            zoom: 16.0,
                            pitch: 60.0,
                          ),
                          null,
                        );
                        await addPin(center.lng, center.lat, label: center.name);
                      }
                    },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: "Select Evacuation Center",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                    ),

                    dropdownBuilder: (context, selectedItem) {
                      if (selectedItem == null) {
                        return Text(
                          "Select Evacuation Center",
                          style: TextStyle(color: const Color(0xFF23552C).withOpacity(0.5),
                          ),
                        );
                      }
                      return Text(
                        "${toTitleCase(selectedItem.barangay)} - ${toTitleCase(selectedItem.name)}",
                        style: TextStyle(
                          color: Color(0xFF23552C),
                          fontVariations: [
                            FontVariation('wght', 450),
                          ],
                          fontSize: 14,
                        ),
                      );
                    },

                    popupProps: PopupProps.menu(
                      constraints: const BoxConstraints(maxHeight: 200),
                      itemBuilder: (context, center, isSelected) {
                        return Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(
                            "${toTitleCase(center.barangay)} - ${toTitleCase(center.name)}",
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              color: Color(0xFF23552C),
                              fontVariations: [
                                FontVariation('wght', 400),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    PhosphorIcons.magnifyingGlass,
                    size: 22.0,
                    color: Color(0xff06370b),
                  ),
                  onPressed: () {
                    if (currentMode == MapMode.Flood && selectedBarangay != null) {
                      goToBarangay(selectedBarangay!);
                    } else if (currentMode == MapMode.Evacuation && selectedCenter != null) {
                      mapboxMap.flyTo(
                        CameraOptions(
                          center: Point(coordinates: Position(selectedCenter!.lng, selectedCenter!.lat)),
                          zoom: 16.0,
                          pitch: 60.0,
                        ),
                        null,
                      );
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("Please select an item")));
                    }
                  },
                ),
              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: Colors.yellow,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Low",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Color(0xFF23552C),
                      fontVariations: [
                        FontVariation('wght', 450),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),

              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Medium",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Color(0xFF23552C),
                      fontVariations: [
                        FontVariation('wght', 450),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),

              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "High",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Color(0xFF23552C),
                      fontVariations: [
                        FontVariation('wght', 450),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          Expanded(
            child: MapWidget(
              styleUri: "mapbox://styles/mapbox/streets-v12",
              cameraOptions: CameraOptions(
                center: Point(coordinates: Position(123.2, 13.63)),
                zoom: 12.0,
                pitch: 60.0,
              ),
              onMapCreated: (MapboxMap map) async {
                mapboxMap = map;

                _pointAnnotationManager =
                await mapboxMap.annotations.createPointAnnotationManager();

                await waitForStyleLoaded();

                await addEvacuationIconToMap();

                if (currentMode == MapMode.Flood) {
                  await addFloodLayer();
                } else {
                  await addEvacuationPinsFromGeoJson();
                }

                final centers = await loadEvacuationCenters();
                setState(() {
                  evacuationCenters = centers;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 20, height: 20, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
