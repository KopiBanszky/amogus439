// ignore_for_file: file_names, curly_braces_in_flow_control_structures

import 'package:amogusvez2/utility/stLessTimer.dart';
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
  int voted = 0; //the player who got voted
  List<Map<String, dynamic>> votes = []; //{player_id, voter_color || grey}
  bool showVotes = false;
  bool preventNewStop = false;

  void listenOnSockets() {
    socket.on("vote", (data) {
      if (data["code"] == 200) {
        setState(() {});
      } else {
        voted = 0;
      }
    });

    socket.on("vote_placed", (data) {
      if (data["code"] == 200) {
        Map<String, dynamic> vote = {};
        if (data["voter"] == -1) {
          vote["voter_color"] = Colors.grey[800];
        } else {
          Player voter = Player.fromMap(data["voter"]);
          vote["voter_color"] = voter.color;
        }

        if (data["voted"] == -1) {
          vote["player_id"] = -1;
        } else {
          vote["player_id"] = data["voted"]["id"];
        }
        votes.add(vote);
        vote = {};
      }
    });

    socket.on("vote_result", (data) {
      print(data);
      if (preventNewStop) return;
      setState(() {
        time = 6;
        showVotes = true;
        preventNewStop = true;
      });
      late Player votedOut;
      if (!data["skip"]) {
        votedOut = Player.fromMap(data["player"]);
      }
      Future.delayed(const Duration(seconds: 7), () {
        Navigator.pushReplacementNamed(context, "/votingResult", arguments: {
          "votedOut": votedOut,
          "skip": data["skip"],
        });
      });
    });
  }

  List<Widget> _buildVoters(int id) {
    List<Widget> voterWidgets = [];
    for (int i = 0; i < votes.length; i++) {
      Map<String, dynamic> vote = votes[i];
      if (vote["player_id"] == id)
        voterWidgets.add(ColorFiltered(
          colorFilter:
              ColorFilter.mode(vote["voter_color"], BlendMode.modulate),
          child: Image.asset(
            "assets/player.png",
            // width: MediaQuery.of(context).size.width * .1,
          ),
        ));
    }
    return voterWidgets;
  }

  Widget _buildPlayer(Player player) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .095,
      width: MediaQuery.of(context).size.width * .45,
      child: ElevatedButton(
          onPressed: (player.dead || voted == player.id)
              ? null
              : () {
                  if (voted != 0 || player.id == plyr.id) return;
                  voted = player.id;
                  socket.emit("vote", {
                    "game_id": gameId,
                    "user_id": plyr.id,
                    "vote_id": player.id,
                  });
                },
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor:
                (voted == player.id) ? Colors.grey[700] : Colors.red[400],
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ColorFiltered(
                    colorFilter:
                        ColorFilter.mode(player.color, BlendMode.modulate),
                    child: Image.asset(
                      "assets/${(reporter.id == player.id) ? (isEmergencyCalled ? "caller.png" : "reporter.png") : (player.dead ? "dead.png" : "player.png")}",
                      height: MediaQuery.of(context).size.height * .04,
                    ),
                  ),
                  Expanded(
                    child: Text(player.name,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ),
                ],
              ),
              if (showVotes)
                SizedBox(
                  height: MediaQuery.of(context).size.height * .02,
                  child: Row(children: _buildVoters(player.id)),
                )
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

  void timer() {
    print(time);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        time--;
      });
      if (time > 0) {
        timer();
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
      socket = arguments['socket'];
      players = arguments['players'];
      isEmergencyCalled = arguments['isEmergencyCalled'];
      reporter = arguments['reporter'];
      dead = arguments['dead'];
      time = arguments['time'];
      loaded = true;

      listenOnSockets();
      timer();
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Szavazás", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[900],
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.grey[900],
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                  isEmergencyCalled ? "Emergency meeting" : "Holttest jelentve",
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
              const Text("Szavazásra idő: ",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              StLessTimer(
                duration: time,
                textColor: Colors.white,
                fontSize: 20,
              ),
              const SizedBox(
                height: 8.0,
              ),
              Flexible(
                // height: MediaQuery.of(context).size.height * .5,

                child: SingleChildScrollView(
                  child: _buildPlayers(players),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .095,
                width: MediaQuery.of(context).size.width * .45,
                child: ElevatedButton(
                    onPressed: voted == -1
                        ? null
                        : () {
                            if (voted != 0) return;
                            voted = -1;
                            socket.emit("vote", {
                              "game_id": gameId,
                              "user_id": plyr.id,
                              "vote_id": -1,
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: Colors.grey[700],
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
                    child: Column(
                      children: [
                        const Text("Skip",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              overflow: TextOverflow.ellipsis,
                            )),
                        if (showVotes)
                          SizedBox(
                            height: 20.0,
                            child: Row(children: _buildVoters(-1)),
                          )
                      ],
                    )),
              )
            ],
          ),
        )),
      ),
    );
  }
}
