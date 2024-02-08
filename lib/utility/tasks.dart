import 'package:amogusvez2/utility/alert.dart';
import 'package:amogusvez2/utility/alertInput.dart';
import 'package:amogusvez2/utility/types.dart';
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
  List<int> tasksHaldDone = [];

  void doTask(String gameId, int taskId, int userId, String taskCode) {
    socket.emit("task_done", {
      "game_id": gameId,
      "task_id": taskId,
      "user_id": userId,
      "task_code": taskCode,
    });
  }

  void listendToSockets(Socket socket) {
    socket.on("task_done", (data) {
      if ((data["code"] % 200) >= 100 || (data["code"] % 400) <= 100) {
        showAlert("Hiba - ${data["code"]}", data["message"], Colors.red, true,
            () {}, "Ok", false, () {}, "", context);
        return;
      }
      if (data["code"] == 205) {
        showAlert("Hiba - ${data["code"]}", data["message"], Colors.blue, true,
            () {}, "Ok", false, () {}, "", context);
      }
      if (data["code"] == 203) {
        showAlert("Kettős task", data["message"], Colors.orange, true, () {},
            "Ok", false, () {}, "", context);

        Task newTask = Task.fromMap(data["new_task"]);
        int index = tasks
            .indexOf(tasks.firstWhere((element) => element.id == data["id"]));
        tasks.replaceRange(index, index + 1, [newTask]);
        tasksHaldDone.add(data["id"]);
      } else
        // ignore: curly_braces_in_flow_control_structures
        tasksDone.add(data["id"]);
      setState(() {
        taskWidgets = _buildTasks(tasks, gameId, userId);
      });
    });
  }

  List<Widget> _buildTasks(List<Task> tasks, String gameId, int userId) {
    List<Widget> taskWidgets = [];
    for (int i = 0; i < tasks.length; i++) {
      Task task = tasks[i];
      taskWidgets.add(Container(
        width: MediaQuery.of(context).size.width * .97,
        height: MediaQuery.of(context).size.height * .07,
        decoration: BoxDecoration(
          color: tasksDone.contains(task.id)
              ? Colors.green
              : tasksHaldDone.contains(task.id)
                  ? Colors.orange
                  : Colors.grey[800],
          borderRadius: BorderRadius.circular(7),
        ),
        child: ElevatedButton(
          onPressed: () async {
            dynamic res = await showAlertInput(
                "Task kód",
                "Írd be a kapott kódot",
                InputType.text,
                "Kód",
                Colors.blue,
                true,
                () {},
                "Kész",
                true,
                () {},
                "Mégse",
                context);

            doTask(gameId, task.id, userId, res["input"]);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.name,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              Icon(
                tasksDone.contains(task.id)
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ));
      taskWidgets.add(const SizedBox(
        height: 5,
      ));
    }
    return taskWidgets;
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      tasks = widget.tasks;
      socket = widget.socket;
      gameId = widget.gameId;
      userId = widget.userId;

      taskWidgets = _buildTasks(tasks, gameId, userId);
      listendToSockets(socket);

      loaded = true;
    }
    return Container(
      width: MediaQuery.of(context).size.width * .97,
      height: MediaQuery.of(context).size.height * .3,
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SingleChildScrollView(
          child: Column(
            children: taskWidgets,
          ),
        ),
      ),
    );
  }
}
