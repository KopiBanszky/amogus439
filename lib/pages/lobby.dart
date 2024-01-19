import 'package:amogusvez2/utility/alert.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../utility/player.dart';
import '../utility/taskbar.dart';
import '../utility/types.dart';
import 'dart:math';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});


  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  bool loaded = false;
  dynamic arguments;
  List<Player> players = [];
  late Game game;
  late bool host;
  late Socket socket;
  late Player me;
  late String gameId;
  late List<int> impostors = [];
  bool updatedOrStarted = false;


//shows the players in a 3xX grid
  List<Row> _buildPlayers(List<Player> players){

    int length = players.length;
    int rows = length ~/ 3 + 1;


    List<Row> playerWidgets = [];
    int db = 0;

    for(int i = 0; i < rows; i++){
      List<PlayerWidget> row = [];
      for(int j = 0; j < 3; j++) {
        if(db >= length) break;
        Player plyr = players[i * 3 + j];
        PlayerWidget playerWidget = PlayerWidget(color: plyr.color, name: plyr.name, isImpostor: false);
        row.add(playerWidget);
        db++;
      }
      playerWidgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: row,
      ));
      if(db >= length) break;
    }

    return playerWidgets;
  }


  //starts to listen to the sockets
  void startListenToSockets(Socket socket, String gameId){
    socket.on("update_players", (data){

      //adds a new player to the list
      Player player = Player.fromMap({
        "id": data["id"],
        "game_id": gameId,
        "socket_id": data["socket_id"],
        "name": data["username"],
        "color": data["color"],
      });

      setState(() {
        players.add(player);
      });
    });

    //removes a player from the list
    socket.on("player_disconnected", (data){
      setState(() {
        players.removeWhere((element) => element.socketId == data["socket_id"]);
      });
    });

    if(host) {
      socket.on("start_game", (data){
        showAlert("Hiba - ${data["code"]}", data["message"], Colors.red, true, () {}, "Ok", false, () {}, "", context);
      });
    }

    socket.on("role_update", (data) {
      print("1: ${data["player"]}");
      me.tasks = List<int>.from(data["player"]["tasks"] ?? []);
      me.team = data["player"]["team"] ? true : false;

      impostors = List<int>.from(data["impostors"] ?? []);
    });

    socket.on("game_started", (data){
      if(data["code"] != 200) {
        showAlert("Hiba - ${data["code"]}", data["message"], Colors.red, true, () {}, "Ok", false, () {}, "", context);
        return;
      }
      Game resGame= Game.fromMap(data["game"]);

      Navigator.pushReplacementNamed(context, "/roleReveal", arguments: {
        "host": host,
        "gameId": gameId,
        "player": me,
        "impostors": impostors,
        "socket": socket,
        "game": resGame,
        "players": players.length,
      });
    });

  }

  void startGame(){
    Navigator.pushNamed(context, "/roleReveal", arguments: {
      "host": host,
      "gameId": gameId,
      "player": me,
      "impostors": impostors,
    });
  }



  @override
  Widget build(BuildContext context) {

    //if the page is loaded, then it will not load again
    if(!loaded) {
      arguments = ModalRoute
          .of(context)!
          .settings
          .arguments;
      host = arguments["host"];
      socket = arguments["socket"];
      gameId = arguments["gameId"].toString();
      if (host) {
        players.add(arguments["player"]);
        game = arguments["game"];
      }
      else {
        players = arguments["players"];
      }


      me = players.firstWhere((element) => element.socketId == socket.id);

      startListenToSockets(socket, arguments["gameId"].toString());



      loaded = true;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: me.color,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
          const Text("Amogus-vez",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Text("ID: $gameId",
              style: const TextStyle(
                color: Colors.white,
              ),
            )
          ],
        )
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8.0,),
            if(host) Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    socket.emit("start_game", {
                      "game_id": gameId,
                      "user_id": me.id,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Colors.grey,
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                    side: const BorderSide(
                      color: Colors.white,
                      width: 1.5,
                    ),
                    fixedSize: Size(MediaQuery.of(context).size.width * .45, 55),
                    textStyle: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  child: const Text("Start",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      dynamic result = await Navigator.pushNamed(context, "/settings", arguments: {
                        "host": host,
                        "gameId": gameId,
                        "userID": me.id,
                        "game": game,
                        "player": me,
                      });

                      if(result != null) game = result;
                    },
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
                    fixedSize: Size(MediaQuery.of(context).size.width * .45, 55),
                    textStyle: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  child: const Text("Beállítások",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            if(host) const SizedBox(height: 20),
            const Text("Játékosok",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _buildPlayers(players),
            )
          ],
        ),
      ),
    );
  }





}
