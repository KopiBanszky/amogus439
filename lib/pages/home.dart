// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures, must_call_super

import 'dart:convert';

import 'package:amogusvez2/connections/http.dart';
import 'package:amogusvez2/utility/alertInput.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../connections/socketio.dart';
import '../utility/alert.dart';
import '../utility/types.dart';

enum BtnTap { join, create }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool connectionAvailable = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController roomController = TextEditingController();

  @override
  void initState() {
    checkConnection().then((available) => {
          print(available),
          if (available)
            {
              setState(() {
                connectionAvailable = true;
                _requestLocationPermissions();
                // _requestCameraPermission();
              })
            }
        });
  }

  Future<void> _requestLocationPermissions() async {
    PermissionStatus alreadzGranted = await Permission.location.status;
    if (alreadzGranted.isGranted) {
      _requestCameraPermission();
      return;
    }
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
    } else {
      showAlert(
          "GPS",
          "Kérlek engedélyezd a pontos helymeghatározást, nélküle sajnos nem tudsz játszani.",
          Colors.blue,
          true,
          _requestLocationPermissions,
          "Ok",
          false,
          () {},
          "",
          context);
    }
  }
  

//TODO: ne egyszerre kerjen engedelyt a kamera es a helymeghatározás
  void _requestCameraPermission() async {
      PermissionStatus status = await Permission.camera.request();
      if (status.isGranted) {
        // Permission granted
      } else {
        showAlert(
            "Kamera",
            "Kérlek engedélyezd a kamera használatát, nélküle sajnos nem tudsz játszani.",
            Colors.blue,
            true,
            _requestCameraPermission,
            "Ok",
            false,
            () {},
            "",
            context);
      }}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[900],
        body: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset("assets/background.jpg"),

              //if network or server not available, show it
              if (!connectionAvailable)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        "Nem sikerült kapcsolódni az szerverhez...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            onPressed: () {
                              initState();
                            },
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.blue,
                              size: 100,
                            ),
                          ))
                    ],
                  ),
                ),

              const SizedBox(
                height: 20,
              ),

              //if connection available, show text inputs and btns
              //first two element in the column are text and number inputs (name, roomid)

              if (connectionAvailable)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: "Név",
                          hintStyle: TextStyle(
                            color: Colors.white,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ], // Only numbers can be entered
                        controller: roomController,
                        decoration: const InputDecoration(
                          hintText: "Szoba kód",
                          hintStyle: TextStyle(
                            color: Colors.white,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      //btns to join or host game
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () => validateBtn(BtnTap.join),
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor: Colors.grey,
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              padding:
                                  const EdgeInsets.fromLTRB(25, 15, 25, 15),
                              side: const BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            child: const Text("Csatlakozás",
                                style: TextStyle(
                                  color: Colors.white,
                                )),
                          ),
                          ElevatedButton(
                            onPressed: () => validateBtn(BtnTap.create),
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor: Colors.grey,
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              padding:
                                  const EdgeInsets.fromLTRB(25, 15, 25, 15),
                              side: const BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            child: const Text("Létrehozás",
                                style: TextStyle(
                                  color: Colors.white,
                                )),
                          ),
                        ],
                      ),
                      /*ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/qrReader');
                      },
                      child: const Text("Qr-kód olvasó",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )
                  ),*/
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              dynamic res = await showAlertInput(
                                  "Jelszó",
                                  "Írd be a jelszót!",
                                  InputType.password,
                                  "Jelszó",
                                  Colors.red,
                                  true,
                                  () {},
                                  "Ok",
                                  true,
                                  () {},
                                  "Mégse",
                                  context);

                              if (res != null) {
                                http_post("api/manager/login",
                                    {"password": res["input"]}).then((value) {
                                  dynamic data = jsonDecode(value.data);
                                  if (data["ok"]) {
                                    Navigator.pushNamed(context, "/admin");
                                  } else {
                                    showAlert(
                                        "Hiba",
                                        "Hibás jelszó!",
                                        Colors.red,
                                        true,
                                        () {},
                                        "Ok",
                                        false,
                                        () {},
                                        "",
                                        context);
                                  }
                                });
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              )),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.fromLTRB(25, 15, 25, 15)),
                              side: MaterialStateProperty.all(const BorderSide(
                                color: Colors.white,
                                width: 1.5,
                              )),
                              textStyle:
                                  MaterialStateProperty.all(const TextStyle(
                                fontSize: 20,
                              )),
                            ),
                            child: const Text(
                              "Manager Page",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // ElevatedButton(
                      //     onPressed: () {
                      //       Navigator.pushNamed(context, '/navigation');
                      //     },
                      //     child: const Text("test"))
                    ],
                  ),
                )
            ],
          ),
        ));
  }

  //pings the server, to check if its available
  Future<bool> checkConnection() async {
    try {
      RquestResult res = await http_get("/check");
      print(res.ok);

      if (res.ok) {
        return true;
      } else
        return false;
    } catch (e) {
      print("Err:");
      print(e);
      return false;
    }
  }

  //checks witch btn is pressed, and if the needed values are valid
  void validateBtn(BtnTap btn) {
    _requestCameraPermission();

    if (btn == BtnTap.join) {
      if (nameController.text.trim() == "" ||
          roomController.text.trim() == "" ||
          roomController.text.trim().length != 6 ||
          nameController.text.trim().length > 20 ||
          nameController.text.trim().length < 3) {
        showAlert("Hiba", "Hibás adatok!", Colors.red, true, () {}, "Ok", false,
            () {}, "", context);
      } else {
        joinRoom();
      }
    } else {
      if (nameController.text.trim() == "" ||
          nameController.text.trim().length > 20 ||
          nameController.text.trim().length < 3) {
        showAlert("Hiba", "Hibás adatok!", Colors.red, true, () {}, "Ok", false,
            () {}, "", context);
      } else {
        createRoom();
      }
    }
  }

  void joinRoom() async {
    RquestResult res = await http_post("api/game/join/join_game",
        {"username": nameController.text, "game_id": roomController.text});

    Map<String, dynamic> data = jsonDecode(res.data);

    if (!res.ok) {
      showAlert(
          "Internal server error",
          "There was an error, and got no response",
          Colors.red,
          false,
          () {},
          "",
          true,
          () {},
          "Ok",
          context);
      return;
    }

    if (data is String) {
      showAlert("Error", "Internal Server error - 505", Colors.red, false,
          () {}, "", true, () {}, "Ok", context);
      return;
    }

    if (data["ok"]) {
      Socket socket = await connectToWebsocket();
      socket.emit("join_game",
          {"username": nameController.text, "game_id": roomController.text});
      socket.on("join_game", (msg) {
        if (msg["code"] != 200) {
          showAlert("Hiba", msg["message"], Colors.red, false, () {}, "", true,
              () {}, "Ok", context);
          return;
        }

        List<Player> players = [];
        for (Map<String, dynamic> player in msg["players"]) {
          player["tasks"] = [];
          players.add(Player.fromMap(player));
        }

        Map<String, dynamic> usableData = {
          "host": false,
          "socket": socket,
          "gameId": roomController.text,
          "players": players,
          "game": {},
        };

        Navigator.pushReplacementNamed(context, "/lobby",
            arguments: usableData);
      });
    } else {
      showAlert("Hiba", data["message"], Colors.red, false, () {}, "", true,
          () {}, "Ok", context);
    }
  }

  void createRoom() async {
    RquestResult res = await http_post("api/game/host/create_game", {
      "username": nameController.text,
    });

    Map<String, dynamic> data = jsonDecode(res.data);

    if (!res.ok) {
      showAlert(
          "Internal server error",
          "There was an error, and got no response",
          Colors.red,
          false,
          () {},
          "",
          true,
          () {},
          "Ok",
          context);
      return;
    }

    if (data is String) {
      showAlert("Error", "Internal Server error - 505", Colors.red, false,
          () {}, "", true, () {}, "Ok", context);
      return;
    }

    Socket socket = await connectToWebsocket();
    socket.emit("create_game",
        {"username": nameController.text, "game_id": data["game_id"]});
    socket.on("create_game", (msg) {
      if (msg["code"] != 200) {
        showAlert("Hiba", msg["message"], Colors.red, false, () {}, "", true,
            () {}, "Ok", context);
        return;
      }

      Map<String, dynamic> usableData = {
        "host": true,
        "socket": socket,
        "gameId": data["game_id"],
        "player": Player.fromMap(msg["data"]["player"]),
        "game": Game.fromMap(msg["data"]["game"]),
      };

      Navigator.pushReplacementNamed(context, "/lobby", arguments: usableData);
    });
  }
}
