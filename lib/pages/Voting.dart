// ignore_for_file: file_names

import 'package:amogusvez2/utility/types.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class VotingPage extends StatefulWidget {
  const VotingPage({super.key});

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  bool loaded = false;
  dynamic arguments;

  late bool
      isEmergencyCalled; //true if emergency is called, false if report is called
  late Player reporter; //the player who reported the body
  late Player dead; //the player who is dead
  late Player plyr; //the player who is playing
  late String gameId; //the id of the game
  late bool host; //true if the player is the host, false if not
  late Socket socket; //the socket of the player
  late List<Player> players; //the players in the game
  late int time; //the time of the voting

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments;
    if (!loaded) {
      plyr = arguments['player'];
      gameId = arguments['gameId'];
      host = arguments['host'];
      socket = arguments['socket'];
      players = arguments['players'];
      isEmergencyCalled = arguments['isEmergencyCalled'];
      reporter = arguments['reporter'];
      dead = arguments['dead'];
      time = arguments['time'];
      loaded = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Szavazás"),
      ),
      backgroundColor: Colors.grey[900],
      body: Center(
          child: Column(
        children: [
          Text(isEmergencyCalled ? "Emergency meeting" : "Holttest jelentve"),
          Text("$time"),
          SizedBox(
            height: MediaQuery.of(context).size.height * .5,
            width: MediaQuery.of(context).size.width * .5,
            child: GridView.count(
                crossAxisCount: 2,
                children:
                    List.from(players.map((Player player) => ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: Colors.grey,
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                          side: const BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  plyr.color, BlendMode.modulate),
                              child: Image.asset(
                                "assets/${(reporter.id == player.id) ? (isEmergencyCalled ? "caller.png" : "reporter.png") : (player.dead ? "dead.png" : "player.png")}",
                                width: MediaQuery.of(context).size.width * .1,
                              ),
                            ),
                            Text(player.name),
                          ],
                        ))))),
          ),
        ],
      )),
    );
  }
}
