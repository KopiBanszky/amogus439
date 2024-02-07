// ignore_for_file: curly_braces_in_flow_control_structures, file_names

import 'dart:convert';

import 'package:amogusvez2/connections/http.dart';
import 'package:amogusvez2/utility/alert.dart';
import 'package:amogusvez2/utility/player.dart';
import 'package:amogusvez2/utility/types.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class WaitingPage extends StatefulWidget {
  const WaitingPage({super.key});

  @override
  State<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {
  dynamic arguments;
  bool loaded = false;

  late bool
      isEmergencyCalled; //true if emergency is called, false if report is called
  late Player reporter; //the player who reported the body
  late Player dead; //the player who is dead
  late Player plyr; //the player who is playing
  late String gameId; //the id of the game
  late bool host; //true if the player is the host, false if not
  late Socket socket; //the socket of the player
  List<Player> players = []; //the players in the game
  bool ok = false;

  Future<void> getPlayers() async {
    RquestResult result = await http_get("api/game/ingame/getPlayers", {
      "game_id": gameId,
    });
    if (result.ok) {
      dynamic data = jsonDecode(jsonDecode(result.data));
      for (int i = 0; i < data["players"].length; i++) {
        Player plyr = Player.fromMap(data["players"][i]);
        players.add(plyr);
      }
      setState(() {
        ok = true;
      });
    }
  }

  void listenToSocket() {
    socket.on("start_vote", (data) {
      if (data["code"] == 200) if (mounted)
        Navigator.pushReplacementNamed(context, "/voting", arguments: {
          "player": plyr,
          "gameId": gameId,
          "host": host,
          "socket": socket,
          "isEmergencyCalled": isEmergencyCalled,
          "reporter": reporter,
          "dead": isEmergencyCalled ? null : dead,
          "time": data["vote_time"],
          "players": players,
        });
      else {
        showAlert(
            "Hiba - unknown",
            "Nem lehet szavazást indítani\nIsmeretlen hiba",
            Colors.red,
            true,
            () {},
            "Ok",
            false,
            () {},
            "",
            context);
      }
      else {
        showAlert(
            "Hiba - ${data["code"]}",
            "Nem lehet szavazást indítani\n${data["message"]}",
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

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments;
    if (!loaded) {
      plyr = arguments['player'];
      gameId = arguments['gameId'];
      host = arguments['host'];
      isEmergencyCalled = arguments['isEmergencyCalled'];
      reporter = arguments['reporter'];
      if (!isEmergencyCalled) dead = arguments!['dead'];
      socket = arguments['socket'];

      getPlayers();
      listenToSocket();

      loaded = true;
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                isEmergencyCalled
                    ? "Emergency összehívve ${reporter.name} által"
                    : "${dead.name} holtteste jelentve ${reporter.name} által",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(
                height: 8.0,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!isEmergencyCalled)
                      PlayerWidget(
                          color: dead.color,
                          name: dead.name,
                          img: imgType.dead),
                    PlayerWidget(
                        color: reporter.color,
                        name: reporter.name,
                        img: isEmergencyCalled
                            ? imgType.emergency
                            : imgType.report)
                  ],
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              const Text(
                "Várakozás a szavazás indítására...",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(
                height: 8.0,
              ),
              if (host)
                ElevatedButton(
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
                  child: const Text("Szavazás indítása",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  onPressed: () {
                    if (ok) {
                      socket.emit("start_vote", {
                        "game_id": gameId,
                        "user_id": plyr.id,
                      });
                    } else {
                      showAlert("Betöltés", "Bróbáld újra", Colors.blue, true,
                          () {}, "Ok", false, () {}, "", context);
                    }
                  },
                )
            ],
          ),
        )),
      ),
    );
  }
}
