import 'dart:convert';

import 'package:amogusvez2/connections/http.dart';
import 'package:amogusvez2/utility/player.dart';
import 'package:flutter/material.dart';

import '../utility/types.dart';

class RoleRevealPage extends StatefulWidget {
  const RoleRevealPage({super.key});

  @override
  State<RoleRevealPage> createState() => _RoleRevealPageState();
}

class _RoleRevealPageState extends State<RoleRevealPage> {
  bool loaded = false;
  dynamic arguments;
  late Player plyr;
  late String gameId;
  late bool host;
  late String name_role;
  late List<Player> impostors = [];
  bool tapped = false;

  Future<void> getImposors(List<int> ids) async {
    for(int i = 0; i < ids.length; i++){
      int id = ids[i];
      print(id);
      RquestResult result = await http_get("api/game/ingame/getPlayer", {
        "user_id": id.toString(),
      });
      if(result.ok){
        dynamic data = jsonDecode(jsonDecode(result.data));
        print(data);


        Player plyr = Player.fromMap(data["player"]);
        setState(() {
          impostors.add(plyr);
        });
      }

    }
  }


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
        PlayerWidget playerWidget = PlayerWidget(color: plyr.color, name: "${plyr.name} - Impostor");
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

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments;
    if(!loaded){
      plyr = arguments['player'];
      gameId = arguments['gameId'];
      host = arguments['host'];
      name_role = plyr.name;

      getImposors(arguments['impostors']);

      loaded = true;
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: ElevatedButton(
        onPressed: () {
          if(!tapped) {
            setState(() {
              tapped = true;
              name_role = "${plyr.name} - ${plyr.team ? "Impostor" : "Crewmate"}";
            });
          }
          else {
            Navigator.pushNamed(context, "/game", arguments: {
              "player": plyr,
              "gameId": gameId,
              "host": host,
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/background.jpg",
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.contain,
              ),
              if(!plyr.team || !tapped/* || impostors.length == 1*/) PlayerWidget(
                  color: plyr.color,
                  name: name_role
              ),
              if(plyr.team && tapped/* && impostors.length > 1*/) Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _buildPlayers(impostors),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * .05),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(!tapped ?
                    "Kattints a képernyőre a szereped felfedéséhez!" :
                    "Te ${plyr.team ? "imporstor" : "crewmate"} vagy! Kattints a képernyőre a folytatáshoz!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}
