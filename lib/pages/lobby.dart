import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../utility/player.dart';
import '../utility/types.dart';

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
        PlayerWidget playerWidget = PlayerWidget(color: plyr.color, name: plyr.name);
        row.add(playerWidget);
        db++;
      }
      playerWidgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: row,
      ));
      if(db >= length) break;
    }

    return playerWidgets;
  }

  void startListenToSockets(socket, gameId){
    print(gameId);
    socket.on("update_players", (data){
      print(gameId);
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
  }



  @override
  Widget build(BuildContext context) {
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          const Text("Amogusvez",
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
            SizedBox(height: 8.0,),
            if(host) Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {},
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
