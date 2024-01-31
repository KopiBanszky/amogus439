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

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments;
    if (!loaded) {
      plyr = arguments['player'];
      gameId = arguments['gameId'];
      host = arguments['host'];
      isEmergencyCalled = arguments['isEmergencyCalled'];
      reporter = arguments['reporter'];
      dead = arguments!['dead'];
      socket = arguments['socket'];
      loaded = true;
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              isEmergencyCalled
                  ? "Emergency összehívve ${reporter.name} által"
                  : "${dead.name} holtteste jelentve ${reporter.name} által",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isEmergencyCalled)
                    PlayerWidget(
                        color: dead.color, name: dead.name, img: imgType.dead),
                  PlayerWidget(
                      color: reporter.color,
                      name: reporter.name,
                      img: isEmergencyCalled
                          ? imgType.emergency
                          : imgType.report)
                ],
              ),
            ),
            const Text(
              "Várakozás a szavazás indítására...",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            if (host)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/voting",
                      arguments: {
                        "player": plyr,
                        "gameId": gameId,
                        "host": host,
                        "socket": arguments['socket'],
                        "game": arguments['game'],
                        "players": arguments['players'],
                        "tasks": arguments['tasks'],
                        "isEmergencyCalled": isEmergencyCalled,
                        "reporter": reporter,
                        "dead": dead,
                      });
                },
                child: const Text("Szavazás indítása"),
              )
          ],
        ),
      ),
    );
  }
}
