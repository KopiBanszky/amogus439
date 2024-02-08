import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

Future<LatLng> getGeoPos() async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);

  return LatLng(position.latitude, position.longitude);
}
