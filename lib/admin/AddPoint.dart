// ignore_for_file: curly_braces_in_flow_control_structures, non_constant_identifier_names, file_names

import 'dart:convert';

import 'package:amogusvez2/connections/http.dart';
import 'package:amogusvez2/utility/alert.dart';
import 'package:amogusvez2/utility/types.dart';
import 'package:amogusvez2/utility/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class AddPointPage extends StatefulWidget {
  const AddPointPage({super.key});

  @override
  State<AddPointPage> createState() => _AddPointPageState();
}

class _AddPointPageState extends State<AddPointPage> {
  final TextEditingController _mapController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  List<String> values = ["-1", "0", "1", "12", "2", "3", "4", "42"];
  List<String> maps = [];
  Map<String, String> types = {
    "-1": "Select type!",
    "0": "Simple task",
    "1": "Dual task first",
    "12": "Dual task sec",
    "2": "Constant point",
    "3": "Solo sabotage",
    "4": "Dual sabotage first",
    "42": "Dual sabotage sec",
  };
  String selectedType = "-1";
  // Position? userLocation =

  void getMaps() async {
    RquestResult res = await http_get("api/manager/maps");
    if (res.ok) {
      dynamic data = jsonDecode(jsonDecode(res.data));
      for (int i = 0; i < data["maps"].length; i++) {
        if (!maps.contains(data["maps"][i]["map"])) {
          maps.add(data["maps"][i]["map"]);
        }
      }
      if (mounted)
        setState(() {
          maps = maps;
        });
    }
  }

  List<Task> tasks = [
    Task(
        connect_id: 0,
        geoPos: {"lat": 0, "lon": 0},
        id: 0,
        map: "",
        name: "Válassz párt!",
        code: "",
        type: 0),
  ];
  List<Task> tasks_forDisplay = [];
  Task selectedTask = Task(
      connect_id: 0,
      geoPos: {"lat": 0, "lon": 0},
      id: 0,
      map: "",
      name: "Válassz párt!",
      code: "",
      type: 0);

  void getTasks() async {
    RquestResult res = await http_get("api/manager/get_tasks");
    if (res.ok) {
      dynamic data = jsonDecode(jsonDecode(res.data));
      for (int i = 0; i < data["message"].length; i++) {
        Task task = Task(
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
        );
        if (_mapController.text != "") {
          if (task.map == _mapController.text) {
            if (task.type == (int.parse(selectedType) ~/ 10)) tasks.add(task);
            tasks_forDisplay.add(task);
          }
        } else {
          if (task.type == (int.parse(selectedType) ~/ 10)) tasks.add(task);
          tasks_forDisplay.add(task);
        }
      }
      setState(() {
        tasks = tasks;
        _displayTasks();
      });
    }
  }

  // Method that uses location plugin

  MapboxMapController? mapboxMap;
  bool imgsAdded = false;

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

  _displayTasks() {
    mapboxMap!.clearSymbols();
    for (int i = 0; i < tasks_forDisplay.length; i++) {
      Task task = tasks_forDisplay[i];
      if (task.type < 2 || task.type == 12) {
        mapboxMap!.addSymbol(
          SymbolOptions(
            geometry: LatLng(task.geoPos["lat"]!, task.geoPos["lon"]!),
            iconImage: "task",
            iconSize: 0.15,
            textHaloWidth: 1.5,
          ),
        );
      } else if (task.type > 2) {
        mapboxMap!.addSymbol(
          SymbolOptions(
            geometry: LatLng(task.geoPos["lat"]!, task.geoPos["lon"]!),
            iconImage: "sabotage",
            iconSize: 0.15,
            textHaloWidth: 1.5,
          ),
        );
      } else {
        mapboxMap!.addSymbol(
          SymbolOptions(
            geometry: LatLng(task.geoPos["lat"]!, task.geoPos["lon"]!),
            iconImage: "location",
            iconSize: 0.15,
            textHaloWidth: 1.5,
          ),
        );
      }
    }
    // mapboxMap!.addSymbol(

    // )
    //   var options = <PointAnnotationOptions>[];

    //     options.add(PointAnnotationOptions(
    //       geometry: Point(
    //         coordinates: Position(task.geoPos["lon"]!, task.geoPos["lat"]!),
    //       ).toJson(),
    //       image: list,
    //       iconSize: .15,
    //       textHaloWidth: 1.5,
    //     ));
    //   }
    //   pointAnnotationManager.createMulti(options);
    // });
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
      if(value != null) mapboxMap.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: value,
            zoom: 16.5,
          ),
        ),
      );

      else {
        showAlert("Hely", "Kapcsold be a helymeghatározást", Colors.red, true, () {}, "Ok", false, () {}, "", context);
      }
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
    getMaps();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Point"),
        backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownMenu(
              controller: _mapController,
              requestFocusOnTap: true,
              label: const Text(
                "Map",
                style: TextStyle(color: Colors.white),
              ),
              onSelected: (String? value) {
                getTasks();
              },
              menuStyle: MenuStyle(
                backgroundColor: MaterialStateProperty.all(Colors.grey[800]),
              ),
              width: MediaQuery.of(context).size.width * .95,
              textStyle: const TextStyle(color: Colors.white),
              dropdownMenuEntries: maps.map<DropdownMenuEntry<String>>((map) {
                return DropdownMenuEntry<String>(
                    value: map,
                    label: map,
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.grey[800]),
                      textStyle: MaterialStateProperty.all(
                        const TextStyle(color: Colors.white),
                      ),
                    ));
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * .8,
              child: DropdownButton(
                value: selectedType,
                icon: const Icon(
                  Icons.map,
                  color: Colors.grey,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                dropdownColor: Colors.grey[900],
                items: values.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      types[value]!,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedTask = tasks[0];
                    getTasks();
                    selectedType = value!;
                  });
                },
              ),
            ),
          ),
          if ((int.parse(selectedType) % 10) == 2 && selectedType != "2")
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * .8,
                child: DropdownButton(
                  value: selectedTask.id.toString(),
                  icon: const Icon(
                    Icons.task,
                    color: Colors.grey,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  dropdownColor: Colors.grey[900],
                  items: tasks.map<DropdownMenuItem<String>>((Task task) {
                    return DropdownMenuItem<String>(
                      value: task.id.toString(),
                      child: Text(
                        "${task.name}${_mapController.text == "" ? " - ${task.map}" : ""}",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedTask = tasks.firstWhere((element) {
                        return element.id.toString() == value;
                      });
                    });
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                showAlert(
                    "Mentés",
                    "A task pillanatokon belül mentve lesz. Kérlek ne zárd be ezt az ablakot!",
                    Colors.green,
                    false,
                    () {},
                    "",
                    false,
                    () {},
                    "",
                    context);
                getGeoPos().then((value) {

                  if (value != null) http_post("api/manager/task_upload", {
                    "task_name": _nameController.text,
                    "type": selectedType,
                    "connect_id": selectedTask.id.toString(),
                    "geo_pos": {
                      "lat": value.latitude,
                      "lon": value.longitude,
                    },
                    "map": _mapController.text,
                  }).then((value) {
                    if (value.ok) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  });
                  else {
                    showAlert("Hely", "Kapcsold be a helymeghatározást", Colors.red, true, () {}, "Ok", false, () {}, "", context);
                  }
                });
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.lightGreen[700]),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                )),
                padding: MaterialStateProperty.all(
                    const EdgeInsets.fromLTRB(25, 15, 25, 15)),
                side: MaterialStateProperty.all(const BorderSide(
                  color: Colors.white,
                  width: 1.5,
                )),
                textStyle: MaterialStateProperty.all(const TextStyle(
                  fontSize: 20,
                )),
              ),
              child: const Text(
                "Add Point",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: MapboxMap(
              accessToken:
                  "pk.eyJ1Ijoia29waWJvaSIsImEiOiJjbHFjdGZ3dGEwNXFsMmtycTUzZHRqNXJvIn0.haRdnumlvJ5AIQ88GIe-bA",
              key: const ValueKey("mapWidget"),
              onMapCreated: _onMapCreated,
              styleString: MapboxStyles.SATELLITE_STREETS,
              initialCameraPosition: const CameraPosition(
                target: LatLng(47.4451677, 18.913277),
                zoom: 16.5,
              ),
              myLocationEnabled: true,
              // myLocationRenderMode: MyLocationRenderMode.NORMAL,
              // myLocationTrackingMode: MyLocationTrackingMode.Tracking,
            ),
          ),
        ],
      ),
    );
  }
}
