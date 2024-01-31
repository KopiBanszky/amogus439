import 'dart:convert';

import 'package:amogusvez2/connections/http.dart';
import 'package:amogusvez2/utility/alert.dart';
import 'package:amogusvez2/utility/tasks.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../utility/taskbar.dart';
import '../utility/types.dart';

class GameMainPage extends StatefulWidget {
  const GameMainPage({super.key});

  @override
  State<GameMainPage> createState() => _GameMainPageState();
}

class _GameMainPageState extends State<GameMainPage> {
  bool loaded = false;
  dynamic arguments;
  late Player plyr;
  late String gameId;
  late bool host;
  late List<Player> impostors = [];
  late int players;
  late Game game;
  late Socket socket;
  late List<Task> tasks = [];
  late String qr_action;
  bool alive = true;

  void listenOnSockets() {
    socket.on("got_killed", (data) {
      print(data);
      Player impo = Player.fromMap(data["player"]);
      print("Megölt: ${impo.name}");
      setState(() {
        qr_action = "${plyr.id}-report";
      });
      alive = false;
      showAlert("Meghaltál", "Megölt: ${impo.name}", impo.color, true, () {},
          "Ok", false, () {}, "", context);
    });

    socket.on("reported_player", (data) {
      if (!alive) {
        qr_action = "${plyr.id}-dead";
      }
    });

    socket.on("emergency_called", (data) {
      qr_action = "${plyr.id}-dead";
    });
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments;
    if (!loaded) {
      plyr = arguments['player'];
      gameId = arguments['gameId'];
      host = arguments['host'];
      impostors = arguments['impostors'] ?? [];
      players = arguments['players'];
      game = arguments['game'];
      socket = arguments['socket'];
      tasks = arguments['tasks'] ?? [];
      qr_action = "${plyr.id}-alive";

      listenOnSockets();

      loaded = true;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(plyr.name,
              style: const TextStyle(color: Colors.white, fontSize: 20)),
          ColorFiltered(
            colorFilter: ColorFilter.mode(plyr.color, BlendMode.modulate),
            child: Image.asset(
              "assets/${plyr.team ? "impostor.png" : "player.png"}",
              width: MediaQuery.of(context).size.width * .1,
            ),
          )
        ]),
      ),
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          children: [
            if (game.taskVisible)
              TaskBarWidget(
                socket: socket,
                playersCount: players,
                tasksCount: game.taskNumber,
                impostorsCount: game.impostorMax,
              ),
            if (game.taskVisible)
              const SizedBox(
                height: 10,
              ),
            TasksWidget(
                socket: socket, tasks: tasks, gameId: gameId, userId: plyr.id),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Colors.grey,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                        side: const BorderSide(
                          color: Colors.white,
                          width: 1.5,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      child: const Text(
                        "Térkép",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/qrReader', arguments: {
                          'player': plyr,
                          'socket': socket,
                          'gameId': gameId,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Colors.grey,
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                        side: const BorderSide(
                          color: Colors.white,
                          width: 1.5,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      child: const Text(
                        "Qr-kód olvasó",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )),
                ],
              ),
            ),
            //QR kód
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: QrImageView(
                data: qr_action,
                size: 300,
                version: QrVersions.auto,
                backgroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
