// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:amogusvez2/connections/http.dart';
import 'package:amogusvez2/utility/types.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:socket_io_client/socket_io_client.dart';

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
  bool found = false;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments;
    plyr = arguments['player'];
    color = plyr.color;
    socket = arguments['socket'];
    gameId = arguments['gameId'];
    killEnabled = arguments['killEnabled'];
    

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Qr olvasó",
                style: TextStyle(color: Colors.white, fontSize: 20)),
            ColorFiltered(
              colorFilter: ColorFilter.mode(plyr.color, BlendMode.modulate),
              child: Image.asset(
                "assets/${plyr.team ? "impostor.png" : "player.png"}",
                width: MediaQuery.of(context).size.width * .1,
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
            child: QRView(
              key: qrKey,
              overlay: QrScannerOverlayShape(
                borderRadius: 10,
                borderColor: Colors.red,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
              onQRViewCreated: _onQRViewCreated,
            ),
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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      List<String> data = scanData.code.toString().split("-");
      int target_id = int.parse(data[0]);
      String action = data[1];

      controller.pauseCamera();
      switch (action) {
        case "dead":
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
                controller.resumeCamera();
              }, "Ok", false, () {}, "", context);
            }
          });
          break;
        case "alive":
          if (!plyr.team) {
            showAlert(
                "Megállj!", "A játékos még életben van", Colors.blue, true, () {
              controller.resumeCamera();
            }, "Ok", false, () {}, "", context);
          } else {
            if(!killEnabled){
              showAlert(
                  "Megállj!", "Nem vagy még képes gyilkolni", Colors.blue, true, () {
                controller.resumeCamera();
              }, "Ok", false, () {}, "", context);
              return;
            }


            socket.emit("kill", {
              "game_id": gameId,
              "user_id": plyr.id,
              "target_id": target_id,
            });

            //get player
            socket.on("kill", (data) async {
              if (data["code"] == 200) {
                RquestResult plyr_res = await http_get("api/game/ingame/getPlayer", {
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
                    Navigator.pop(context, {"code": 201});
                  }, "Ok", false, () {}, "", context);
                }
              } else {
                showAlert(
                    "Hiba - ${data["code"]}", data["message"], Colors.red, true,
                    () {
                  controller.resumeCamera();
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
                controller.resumeCamera();
              }, "Ok", false, () {}, "", context);
            }
          });
          break;
        default:
          controller.resumeCamera();
          break;
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
