// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';

import 'package:amogusvez2/connections/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../utility/types.dart';
import '../utility/utilities.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  dynamic arguments;
  MapboxMapController? mapboxMap;
  bool imgsAdded = false;

  List<Task> tasks = [];

  Future<bool> getTasks() async {
    RquestResult res =
        await http_get("api/manager/get_tasks", {"mapName": arguments["map"]});
    if (res.ok) {
      dynamic data = jsonDecode(jsonDecode(res.data));
      for (int i = 0; i < data["message"].length; i++) {
        tasks.add(
          Task(
            id: data["message"][i]["id"],
            name: data["message"][i]["name"],
            code: data["message"][i]["code"],
            map: data["message"][i]["map"],
            type: data["message"][i]["type"],
            connect_id: data["message"][i]["connect_id"],
            geoPos: {
              "lat": data["message"][i]["geo_pos"]["lat"].toDouble(),
              "lon": data["message"][i]["geo_pos"]["lon"].toDouble()
            },
          ),
        );
      }
      return true;
    }
    return false;
  }

  void _displayPoints() {
    for (int i = 0; i < tasks.length; i++) {
      Task task = tasks[i];
      late String type;
      if (task.type < 2)
        type = "task";
      else if (task.type == 12)
        type = "task2";
      else if (task.type > 2)
        continue;
      else if (task.type == 2) type = "location";
      mapboxMap!.addSymbol(
        SymbolOptions(
          geometry: LatLng(
            tasks[i].geoPos["lat"]!,
            tasks[i].geoPos["lon"]!,
          ),
          iconImage: type,
          iconSize: .2,
          textOffset: const Offset(0, 2),
          textHaloWidth: 1,
        ),
      );
    }
  }

  void _addCustomeImgs() async {
    final ByteData byteDataPlyr = await rootBundle.load('assets/player.png');
    final Uint8List bytesPlyr = byteDataPlyr.buffer.asUint8List();
    await mapboxMap!.addImage(
      'player',
      bytesPlyr,
    );
    final ByteData byteDataTask = await rootBundle.load('assets/task.png');
    final Uint8List bytesTask = byteDataTask.buffer.asUint8List();
    await mapboxMap!.addImage(
      'task',
      bytesTask,
    );
    final ByteData byteDataTask2 = await rootBundle.load('assets/task2.png');
    final Uint8List bytesTask2 = byteDataTask2.buffer.asUint8List();
    await mapboxMap!.addImage(
      'task2',
      bytesTask2,
    );
    final ByteData byteDataSab = await rootBundle.load('assets/sabotage.png');
    final Uint8List bytesSab = byteDataSab.buffer.asUint8List();
    await mapboxMap!.addImage(
      'sabotage',
      bytesSab,
    );
    final ByteData byteDataLoc = await rootBundle.load('assets/place.png');
    final Uint8List bytesLoc = byteDataLoc.buffer.asUint8List();
    await mapboxMap!.addImage(
      'location',
      bytesLoc,
    );
    setState(() {
      imgsAdded = true;
    });
  }

  void _initState() {
    getTasks().then((value) {
      if (value) {
        _displayPoints();
      }
    });
  }

  void _onMapCreated(MapboxMapController mapboxMap) async {
    this.mapboxMap = mapboxMap;
    // final ByteData bytes = await rootBundle.load('assets/player.png');
    // final Uint8List list = bytes.buffer.asUint8List();
    // mapboxMap.gestures.updateSettings(GesturesSettings(
    //   quickZoomEnabled: false,
    //   zoomAnimationAmount: 0,
    //   pinchToZoomDecelerationEnabled: false,
    //   pinchToZoomEnabled: false,
    //   doubleTapToZoomInEnabled: false,
    //   doubleTouchToZoomOutEnabled: false,
    //   increasePinchToZoomThresholdWhenRotating: false,
    //   simultaneousRotateAndPinchToZoomEnabled: false,
    //   increaseRotateThresholdWhenPinchingToZoom: false,
    // ));
    getGeoPos().then((value) {
      if (!imgsAdded) _addCustomeImgs();
      mapboxMap.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: value,
            zoom: 16.5,
          ),
        ),
      );
      // mapboxMap.flyTo(
      //   CameraOptions(
      //     center: Point(
      //       coordinates: Position(value.longitude, value.latitude),
      //     ).toJson(),
      //     zoom: 16.5,
      //   ),
      //   MapAnimationOptions(duration: 5000, startDelay: 0),
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments;
    _initState();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Map",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Expanded(
          child: MapboxMap(
            accessToken:
                "pk.eyJ1Ijoia29waWJvaSIsImEiOiJjbHFjdGZ3dGEwNXFsMmtycTUzZHRqNXJvIn0.haRdnumlvJ5AIQ88GIe-bA",
            styleString: MapboxStyles.SATELLITE_STREETS,
            key: const ValueKey("mapWidget"),
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(47.4451677, 18.913277),
              zoom: 16.5,
            ),
            myLocationEnabled: true,
          ),
        ),
      ),
    );
  }
}
