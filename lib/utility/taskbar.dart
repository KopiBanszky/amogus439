import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter/material.dart';

class TaskBarWidget extends StatefulWidget {
  const TaskBarWidget({Key? key, required this.socket,
    required this.playersCount,
    required this.tasksCount,
    required this.impostorsCount,
  }) : super(key: key);

  final Socket socket;
  final int playersCount;
  final int tasksCount;
  final int impostorsCount;

  @override
  State<TaskBarWidget> createState() => _TaskBarWidgetState();
}

class _TaskBarWidgetState extends State<TaskBarWidget> {
  late Socket socket;
  late int players;
  late int tasksCount;
  late int impostors;
  late int maxTasks;

  bool loaded = false;

  int taskbar = 0;
  List<int> tasksDone = [];

  void listenToSockets(Socket socket, String gameId){
    socket.on("task_done_by_crew", (data){
      setState(() {
        tasksDone.add(data);
        taskbar = tasksDone.length ~/ maxTasks;
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    if(!loaded){
      socket = widget.socket;
      players = widget.playersCount;
      tasksCount = widget.tasksCount;
      impostors = widget.impostorsCount;

      maxTasks =  (players - ((players ~/ 3 > impostors) ? impostors : players ~/ 3)) * tasksCount;

      loaded = true;
    }
    return Container(
      width: MediaQuery.of(context).size.width * .97 * taskbar,
      height: 25,
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(0),
        border: Border.all(
          color: Colors.grey[900]!,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * .955,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(0),
              border: Border.all(
                color: Colors.grey[900]!,
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
