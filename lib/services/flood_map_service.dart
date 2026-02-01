import 'dart:convert';
import 'package:flutter/services.dart';

class FloodMapService {
  FloodMapService._internal();
  static final FloodMapService instance = FloodMapService._internal();

  List<Map<String, dynamic>> floodPolygons = [];
  String? geoJsonString;

  Future<void> loadFloodDataOnce() async {
    if (geoJsonString != null) return;

    geoJsonString =
    await rootBundle.loadString("assets/naga_flood.geojson");

    final parsed = jsonDecode(geoJsonString!);
    if (parsed["features"] != null) {
      floodPolygons =
      List<Map<String, dynamic>>.from(parsed["features"]);
    }
  }
}
