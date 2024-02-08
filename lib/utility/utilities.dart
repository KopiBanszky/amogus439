import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

Future<LatLng> getGeoPos() async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);

  return LatLng(position.latitude, position.longitude);
}

enum Platform_name { android, web }

Platform_name getPlatform() {
  if (Platform.isAndroid) {
    return Platform_name.android;
  } else {
    return Platform_name.web;
  }
}
