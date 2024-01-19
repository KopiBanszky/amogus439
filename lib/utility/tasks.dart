import 'package:amogusvez2/utility/types.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class TasksWidget extends StatefulWidget {
  const TasksWidget({
    super.key,
    required this.socket,
    required this.tasks,
    required this.gameId,
    required this.userId,
  });

  final Socket socket;
  final List<Task> tasks;
  final String gameId;
  final int userId;

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  late List<Task> tasks;
  late Socket socket;
  late String gameId;
  late int userId;
  bool loaded = false;
  List<Widget> taskWidgets = [];
  List<int> tasksDone = [];

  void doTask(String gameId, int taskId, int userId){
    tasksDone.add(taskId);
    socket.emit("task_done", {
      "game_id": gameId,
      "task_id": taskId,
      "user_id": userId,
    });
  }

  void listendToSockets(Socket socket){
    socket.on("task_done", (data){
      setState(() {
      });
    });
  }

  List<Widget> _buildTasks(List<Task> tasks, String gameId, int userId) {
    List<Widget> taskWidgets = [];
    for(int i = 0; i < tasks.length; i++){
      Task task = tasks[i];
      print(task.name);
      taskWidgets.add(
        Container(
          width: MediaQuery.of(context).size.width * .97,
          height: MediaQuery.of(context).size.height * .05,
          decoration: BoxDecoration(
            color: tasksDone.contains(task.id) ? Colors.green : Colors.grey[700],
            borderRadius: BorderRadius.circular(7),
          ),
          child: ElevatedButton(
            onPressed: (){
              doTask(gameId, task.id, userId);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(task.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20
                  ),
                ),
                const Icon(Icons.check),

              ],
            ),
          ),
        )
      );
    }
    return taskWidgets;
  }

  @override
  Widget build(BuildContext context) {
    if(!loaded){
      tasks = widget.tasks;
      socket = widget.socket;
      gameId = widget.gameId;
      userId = widget.userId;

      print(tasks.length);

      taskWidgets = _buildTasks(tasks, gameId, userId);
      listendToSockets(socket);

      loaded = true;
    }
    return Container(
      width: MediaQuery.of(context).size.width * .97,
      height: MediaQuery.of(context).size.height * .4,
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(7),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: taskWidgets,
        ),
      ),
    );
  }
}
