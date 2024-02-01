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

  Widget _buildPlayer(Player player) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .1,
      width: MediaQuery.of(context).size.width * .4,
      child: ElevatedButton(
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
                colorFilter: ColorFilter.mode(player.color, BlendMode.modulate),
                child: Image.asset(
                  "assets/${(reporter.id == player.id) ? (isEmergencyCalled ? "caller.png" : "reporter.png") : (player.dead ? "dead.png" : "player.png")}",
                  width: MediaQuery.of(context).size.width * .1,
                ),
              ),
              Text(player.name,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    overflow: TextOverflow.fade,
                  )),
            ],
          )),
    );
  }

  Widget _buildPlayers(List<Player> players) {
    List<Widget> playerWidgets = [];
    List<Widget> row = [];

    for (int i = 0; i < players.length; i++) {
      Player plyr = players[i];
      Widget playerWidget = _buildPlayer(plyr);
      row.add(playerWidget);
      if (i % 2 == 1) {
        playerWidgets.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: row,
        ));
        row = [];
      }
    }

    return Column(
      children: playerWidgets,
    );
  }

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
        title: const Text("Szavazás", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[900],
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(isEmergencyCalled ? "Emergency meeting" : "Holttest jelentve"),
            Text("$time"),
            SizedBox(
              height: MediaQuery.of(context).size.height * .5,
              child: SingleChildScrollView(
                child: _buildPlayers(players),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
