import 'dart:convert';

import 'package:amogusvez2/connections/http.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utility/types.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});



  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool loaded = false;
  dynamic arguments;
  late Player player;
  late Game game;
  late bool host;
  late int userID;
  late String gameId;
  late List<Map<String, String>> mapValues = [{"---": "Válassz pályát"}, {"TestMap1": "Map1"} ];

  final TextEditingController _taskNumberController = TextEditingController();
  final TextEditingController _voteTimeController = TextEditingController();
  final TextEditingController _killCooldownController = TextEditingController();
  final TextEditingController _impostorMaxController = TextEditingController();
  final TextEditingController _emergenciesController = TextEditingController();




  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments;
    //if the page is loaded, then it will not load again
    if(!loaded) {
      arguments = ModalRoute
          .of(context)!
          .settings
          .arguments;
      host = arguments["host"];
      gameId = arguments["gameId"].toString();
      userID = arguments["userID"];
      player = arguments["player"];
      game = arguments["game"];

      _taskNumberController.text = game.taskNumber.toString();
      _voteTimeController.text = game.voteTime.toString();
      _killCooldownController.text = game.killCooldown.toString();
      _impostorMaxController.text = game.impostorMax.toString();
      _emergenciesController.text = game.emergencies.toString();


      loaded = true;
    }


    return Scaffold(
      appBar: AppBar(
        backgroundColor: player.color,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Settings",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Text("ID: ${arguments["gameId"]}",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
        
                //Task number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .7,
                      child: TextField(
                        controller: _taskNumberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ], // Only numbers can be entered
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.task,
                            color: Colors.grey,
                          ),
                          border: const UnderlineInputBorder(),
                          labelText: 'Taskok száma',
                          labelStyle: TextStyle(
                            color: Colors.grey[400],
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            game.taskVisible = !game.taskVisible;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          fixedSize: Size(MediaQuery.of(context).size.width * .2, 55),
                          backgroundColor: game.taskVisible ? Colors.green : Colors.red,
                          side: const BorderSide(
                            color: Colors.white,
                            width: 1.2,
                          ),
                        ),
                        child: Icon(game.taskVisible ? Icons.visibility : Icons.visibility_off,
                          size: 30,
                          color: Colors.white,
                        )
                    )
                  ],
                ),
        
                const SizedBox(height: 10,),
        
                //Vote time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .7,
                      child: TextField(
                        controller: _voteTimeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ], // Only numbers can be entered
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.timer,
                            color: Colors.grey,
                          ),
                          border: const UnderlineInputBorder(),
                          labelText: 'Szavazás ideje (sec)',
                          labelStyle: TextStyle(
                            color: Colors.grey[400],
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            game.anonymousVote = !game.anonymousVote;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          fixedSize: Size(MediaQuery.of(context).size.width * .2, 55),
                          backgroundColor: game.anonymousVote ? Colors.green : Colors.red,
                          side: const BorderSide(
                            color: Colors.white,
                            width: 1.2,
                          ),
                        ),
                        child: Icon(game.anonymousVote ? Icons.visibility : Icons.visibility_off,
                          size: 30,
                          color: Colors.white,
                        )
                    )
                  ],
                ),
        
                const SizedBox(height: 10,),
        
                //Kill cooldown
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: TextField(
                    controller: _killCooldownController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ], // Only numbers can be entered
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.timer,
                        color: Colors.grey,
                      ),
                      border: const UnderlineInputBorder(),
                      labelText: 'Kill cooldown (sec)',
                      labelStyle: TextStyle(
                        color: Colors.grey[400],
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
        
                const SizedBox(height: 10,),
        
                //Impostor max
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: TextField(
                    controller: _impostorMaxController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ], // Only numbers can be entered
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person,
                        color: Colors.grey,
                      ),
                      border: const UnderlineInputBorder(),
                      labelText: 'Impostorok száma',
                      labelStyle: TextStyle(
                        color: Colors.grey[400],
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
        
                const SizedBox(height: 10,),
        
                //Emergencies
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: TextField(
                    controller: _emergenciesController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ], // Only numbers can be entered
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.warning,
                        color: Colors.grey,
                      ),
                      border: const UnderlineInputBorder(),
                      labelText: 'Összehívható emergency meetingek',
                      labelStyle: TextStyle(
                        color: Colors.grey[400],
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
        
                const SizedBox(height: 10,),
        
                //TODO: Map dropwdown menu
                DropdownButton<String>(
                  value: "Válassz pályát",
                  icon: const Icon(Icons.map,
                    color: Colors.grey,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  items: mapValues.map<DropdownMenuItem<String>>((Map<String, String> map) {
                    //TODO: errorozik
                    return DropdownMenuItem<String>(
                      value: map.keys.first,
                      child: Text(map.values.first,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {

                    });
                  },
                ),
        
                const SizedBox(height: 10,),
        
                ElevatedButton(
                    onPressed: () async {
                      RquestResult res = await http_put("api/game/host/settings/update", {
                       "game_id": gameId,
                       "user_id": userID,
                       "task_num": _taskNumberController.text,
                       "task_visibility": game.taskVisible ? 1 : 0,
                       "vote_time": _voteTimeController.text,
                       "anonymus_vote": game.anonymousVote ? 1 : 0,
                       "kill_cooldown": _killCooldownController.text,
                       "impostor_max": _impostorMaxController.text,
                       "emergencies": _emergenciesController.text,
                       "map": "Not Selected",
                     });
                     if(res.ok){
                        game.emergencies = int.parse(_emergenciesController.text);
                        game.impostorMax = int.parse(_impostorMaxController.text);
                        game.killCooldown = int.parse(_killCooldownController.text);
                        game.taskNumber = int.parse(_taskNumberController.text);
                        game.voteTime = int.parse(_voteTimeController.text);
                     }

                      Navigator.pop(context, game);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      fixedSize: Size(MediaQuery.of(context).size.width * .5, 55),
                      backgroundColor: Colors.blue,
                      side: const BorderSide(
                        color: Colors.white,
                        width: 1.2,
                      ),
                    ),
                    child: const Text("Mentés",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
