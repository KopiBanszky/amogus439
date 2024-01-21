import 'dart:convert';

import 'package:amogusvez2/connections/http.dart';
import 'package:amogusvez2/utility/tasks.dart';
import 'package:flutter/material.dart';
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

  Future<List<Task>> _getTasks(List<int> ids) async {
    List<Task> tasksInFunc = [];
    for(int i = 0; i < ids.length; i++){
      RquestResult result = await http_get("api/game/ingame/getTask", {
        "task_id": ids[i].toString(),
      });
      if(result.ok){
        print(result.data);
        dynamic data = jsonDecode(jsonDecode(result.data));
        Task task = Task.fromMap(data["task"]);
        tasksInFunc.add(task);
      }
    }
    setState(() {
      tasks = tasksInFunc;
    });
    return tasksInFunc;
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments;
    if(!loaded){
      plyr = arguments['player'];
      gameId = arguments['gameId'];
      host = arguments['host'];
      impostors = arguments['impostors'] ?? [];
      players = arguments['players'];
      game = arguments['game'];
      socket = arguments['socket'];

      print(plyr.tasks);
      _getTasks(plyr.tasks);

      loaded = true;
    }


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(plyr.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20
              )
            ),
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                  plyr.color,
                  BlendMode.modulate
              ),
              child: Image.asset("assets/${plyr.team ? "impostor.png" : "player.png"}",
                width: MediaQuery.of(context).size.width * .1,

              ),
            )
          ]
        ),
      ),
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          children: [
            if(game.taskVisible) TaskBarWidget(
              socket: socket,
              playersCount: players,
              tasksCount: game.taskNumber,
              impostorsCount: game.impostorMax,
            ),
            if(game.taskVisible) const SizedBox(height: 10,),
            TasksWidget(
                socket: socket,
                tasks: tasks,
                gameId: gameId,
                userId: plyr.id
            )
          ],
        ),
      ),);
  }
}
