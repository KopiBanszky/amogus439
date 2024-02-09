// ignore_for_file: camel_case_types

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

Future<LatLng> getGeoPos() async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  return LatLng(position.latitude, position.longitude);
}

enum Platform_name { android, web }

Platform_name getPlatform() {
  if (kIsWeb) {
    return Platform_name.web;
  } else {
    return Platform_name.android;
  }
}
