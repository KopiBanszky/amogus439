// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, implementation_imports

import 'dart:convert';
// import 'dart:io';

import 'package:amogusvez2/connections/http.dart';
import 'package:amogusvez2/utility/types.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:mobile_scanner/src/enums/camera_facing.dart' as mobile_scanner;

import '../utility/alert.dart';

class SrReaderPage extends StatefulWidget {
  const SrReaderPage({super.key});

  @override
  State<SrReaderPage> createState() => _SrReaderPageState();
}

class _SrReaderPageState extends State<SrReaderPage> {
  dynamic arguments;
  late Color color;
  late Socket socket;
  late String gameId;
  late Player plyr;
  late bool killEnabled;
  late dynamic currentSabotage;
  bool sabotage = false;
  bool reactor = false;
  bool found = false;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  MobileScannerController? controller_scanner = MobileScannerController(
    // ...
    detectionSpeed: DetectionSpeed.normal,
    facing: mobile_scanner.CameraFacing.back,
    torchEnabled: false,
  );
  // QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    controller_scanner!.start();
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments;
    plyr = arguments['player'];
    color = plyr.color;
    socket = arguments['socket'];
    gameId = arguments['gameId'];
    killEnabled = arguments['killEnabled'];
    currentSabotage = arguments['sabotage'];
    reactor = arguments['reactor'];
    sabotage = arguments['sabotageOn'];

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Qr olvasó",
                style: TextStyle(color: Colors.white, fontSize: 20)),
            Hero(
              tag: "appbar-img",
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(plyr.color, BlendMode.modulate),
                child: Image.asset(
                  "assets/${plyr.dead ? "dead.png" : (plyr.team ? "impostor.png" : "player.png")}",
                  width: MediaQuery.of(context).size.width * .1,
                ),
              ),
            )
          ],
        ),
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.grey[850],
      body: Column(
        children: <Widget>[
          Expanded(
              flex: 5,
              child: /*true
                ? */
                  Stack(
                children: [
                  MobileScanner(
                    controller: controller_scanner!,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        final String code = barcode.rawValue!;
                        if (code.startsWith("439amogus-")) {
                          _handleQrData(code, controller_scanner);
                          // controller_scanner!.stop();
                        }
                      }
                    },
                    // scanWindow: Rect.fromCenter(
                    //     center: Offset.zero, width: 10.0, height: 10.0),
                  ),
                  Positioned(
                    bottom: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * .2,
                        height: MediaQuery.of(context).size.width * .2,
                        decoration: BoxDecoration(
                          color: Colors.grey[900]!.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: IconButton(
                          iconSize: 32.0,
                          icon: Icon(
                            Icons.flash_on,
                            color: controller_scanner!.torchEnabled
                                ? Colors.amber
                                : Colors.white,
                          ),
                          onPressed: () {
                            controller_scanner!.toggleTorch();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              )
              // : QRView(
              //     key: qrKey,
              //     overlay: QrScannerOverlayShape(
              //       borderRadius: 10,
              //       borderColor: Colors.red,
              //       borderLength: 30,
              //       borderWidth: 10,
              //       cutOutSize: 300,
              //     ),
              //     onQRViewCreated: _onQRViewCreated,
              //   ),
              ),
          // const Expanded(
          //   flex: 1,
          //   child: Center(
          //       child: Icon(
          //     Icons.qr_code_scanner,
          //     color: Colors.white,
          //     size: 50,
          //   )),
          // ),
        ],
      ),
    );
  }

  // void _onQRViewCreated(QRViewController controller) {
  //   this.controller = controller;
  //   controller.scannedDataStream.listen((scanData) {
  //     controller.pauseCamera();
  //     // _handleQrData(scanData.code.toString(), controller);
  //   });
  // }

  void _handleQrData(String qrString, MobileScannerController? controller) {
    if (controller == null) {
      Navigator.pop(context);
      return;
    }
    // return true to resume camera
    // if (qrString.startsWith("439amogus-")) return;
    List<String> data = qrString.split("-");
    int target_id = int.parse(data[1]);
    String action = data[2];
    if (!(reactor && action == "reactor")) controller.stop();

    switch (action) {
      case "dead":
        showAlert("Megállj!", "A játékos már halott", Colors.blue, true, () {
          // andController!.resumeCamera();
          controller.start();
        }, "Ok", false, () {}, "", context);
        break;
      case "report":
        socket.emit("report", {
          "game_id": gameId,
          "player_id": plyr.id,
          "dead_id": target_id,
        });

        socket.on("report", (data) {
          if (data["code"] != 200) {
            showAlert(
                "Hiba - ${data["code"]}", data["message"], Colors.red, true,
                () {
              // andController!.resumeCamera();
              controller.start();
            }, "Ok", false, () {}, "", context);
          }
        });
        break;
      case "alive":
        if (!plyr.team) {
          showAlert("Megállj!", "A játékos még életben van", Colors.blue, true,
              () {
            // andController!.resumeCamera();
            controller.start();
          }, "Ok", false, () {}, "", context);
        } else {
          if (!killEnabled) {
            showAlert(
                "Megállj!", "Nem vagy még képes gyilkolni", Colors.red, true,
                () {
              // andController!.resumeCamera();
              controller.start();
              Navigator.pop(context);
            }, "Ok", false, () {}, "", context);
            return;
          }

          if (killEnabled)
            socket.emit("kill", {
              "game_id": gameId,
              "user_id": plyr.id,
              "target_id": target_id,
            });

          //get player
          socket.on("kill", (data) async {
            if (!killEnabled) return;
            if (data["code"] == 200) {
              RquestResult plyr_res =
                  await http_get("api/game/ingame/getPlayer", {
                "user_id": target_id.toString(),
              });
              if (plyr_res.ok) {
                dynamic data = jsonDecode(jsonDecode(plyr_res.data));
                Player target = Player.fromMap(data["player"]);
                // ignore: use_build_context_synchronously
                showAlert(
                    "Sikeres gyilkolás",
                    "${target.name}-t sikeresen megölted!",
                    Colors.green,
                    true, () {
                  controller.start();
                  Navigator.pop(context, {"code": 201});
                }, "Ok", false, () {}, "", context);
              }
            } else {
              showAlert(
                  "Hiba - ${data["code"]}", data["message"], Colors.red, true,
                  () {
                // andController!.resumeCamera();
                controller.start();
              }, "Ok", false, () {}, "", context);
            }
          });
        }
        break;
      case "emergency":
        socket.emit("emergency", {
          "game_id": gameId,
          "player_id": plyr.id,
        });
        socket.on("emergency", (data) {
          if (data["code"] != 200) {
            showAlert(
                "Hiba - ${data["code"]}", data["message"], Colors.red, true,
                () {
              // andController!.resumeCamera();
              controller.start();
            }, "Ok", false, () {}, "", context);
          }
        });
        break;

      case "lights":
        if (currentSabotage == null) {
          showAlert("Megállj!", "Nincs aktív sabotázs", Colors.blue, true, () {
            // andController!.resumeCamera();
            controller.start();
          }, "Ok", false, () {}, "", context);
          return;
        }
        socket.emit("fix_simple", {
          "game_id": gameId,
          "user_id": plyr.id,
          "sabotage_id": currentSabotage["game_sb_id"],
          "name": currentSabotage["name"],
        });
        socket.on("fix_simple", (data) {
          if (data["code"] != 200) {
            showAlert(
                "Hiba - ${data["code"]}", data["message"], Colors.red, true,
                () {
              // andController!.resumeCamera();
              controller.start();
            }, "Ok", false, () {}, "", context);
          }
        });
        break;

      case "navigation":
        if (currentSabotage == null) {
          showAlert("Megállj!", "Nincs aktív sabotage", Colors.blue, true, () {
            // andController!.resumeCamera();
            controller.start();
          }, "Ok", false, () {}, "", context);
          return;
        }

        Navigator.popAndPushNamed(context, "/navigation", arguments: {
          "player": plyr,
          "socket": socket,
          "gameId": gameId,
          "sabotage": currentSabotage,
        });

        break;

      case "reactor":
        if (currentSabotage == null) {
          showAlert("Megállj!", "Nincs aktív sabotage", Colors.blue, true, () {
            // andController!.resumeCamera();
            controller.start();
          }, "Ok", false, () {}, "", context);
          return;
        }

        socket.emit("reaktorfix", {
          "game_id": gameId,
          "user_id": plyr.id,
          "game_sb_id": currentSabotage[target_id]["game_sb_id"],
        });

        socket.on("reaktorfix", (data) {
          if (data["code"] != 200) {
            controller.stop();
            showAlert(
                "Hiba - ${data["code"]}", data["message"], Colors.red, true,
                () {
              // andController!.resumeCamera();
              controller.start();
            }, "Ok", false, () {}, "", context);
          }
          // controller.start();
        });

        break;

      default:
        // andController!.resumeCamera();
        controller.start();
        break;
    }
  }

  // @override
  // void dispose() {
  //   controller?.dispose();
  //   super.dispose();
  // }
}
