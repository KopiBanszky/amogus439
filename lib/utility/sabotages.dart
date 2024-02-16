import 'package:amogusvez2/utility/alert.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SabotagesWidget extends StatefulWidget {
  const SabotagesWidget(
      {super.key,
      required this.sabotage,
      required this.socket,
      required this.gameId,
      required this.userId,
      required this.killEnabled});

  final dynamic sabotage;
  final Socket socket;
  final String gameId;
  final int userId;
  final bool killEnabled;

  @override
  State<SabotagesWidget> createState() => _SabotagesWidgetState();
}

class _SabotagesWidgetState extends State<SabotagesWidget> {
  dynamic sabotage;
  late Socket socket;

  @override
  void initState() {
    super.initState();

    socket = widget.socket;
    socket.on("sabotage", (data) {
      if (data["code"] != 200) {
        showAlert("Hiba - ${data["code"]}", data["message"], Colors.red, true,
            () {}, "Ok", false, () {}, "", context);
      }
    });

    socket.off("task_done");
  }

  @override
  Widget build(BuildContext context) {
    sabotage = widget.sabotage;
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
            children: [
              Container(
                width: MediaQuery.of(context).size.width * .97,
                height: MediaQuery.of(context).size.height * .07,
                decoration: BoxDecoration(
                  color: sabotage == null
                      ? Colors.grey[800]
                      : sabotage["name"] == "Reaktor"
                          ? Colors.red
                          : Colors.grey[900],
                  borderRadius: BorderRadius.circular(7),
                ),
                child: ElevatedButton(
                  onPressed: sabotage == null
                      ? () {
                          widget.socket.emit("sabotage", {
                            "game_id": widget.gameId,
                            "user_id": widget.userId,
                            "sabotage": "Reaktor",
                          });
                        }
                      : null,
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
                        "Reaktor",
                        style: TextStyle(
                            color: sabotage == null
                                ? Colors.white
                                : sabotage["name"] == "Reaktor"
                                    ? Colors.white
                                    : Colors.grey[300],
                            fontSize: 20),
                      ),
                      const Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image(
                          image: AssetImage("assets/reactor.png"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width * .97,
                height: MediaQuery.of(context).size.height * .07,
                decoration: BoxDecoration(
                  color: sabotage == null
                      ? Colors.grey[800]
                      : sabotage["name"] == "Lights"
                          ? Colors.red
                          : Colors.grey[900],
                  borderRadius: BorderRadius.circular(7),
                ),
                child: ElevatedButton(
                  onPressed: sabotage == null
                      ? () {
                          widget.socket.emit("sabotage", {
                            "game_id": widget.gameId,
                            "user_id": widget.userId,
                            "sabotage": "Lights",
                          });
                        }
                      : null,
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
                        "Fények",
                        style: TextStyle(
                            color: sabotage == null
                                ? Colors.white
                                : sabotage["name"] == "Lights"
                                    ? Colors.white
                                    : Colors.grey[300],
                            fontSize: 20),
                      ),
                      const Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image(
                          image: AssetImage("assets/lights.png"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width * .97,
                height: MediaQuery.of(context).size.height * .07,
                decoration: BoxDecoration(
                  color: sabotage == null
                      ? Colors.grey[800]
                      : sabotage["name"] == "Navigation"
                          ? Colors.red
                          : Colors.grey[900],
                  borderRadius: BorderRadius.circular(7),
                ),
                child: ElevatedButton(
                  onPressed: sabotage == null
                      ? () {
                          widget.socket.emit("sabotage", {
                            "game_id": widget.gameId,
                            "user_id": widget.userId,
                            "sabotage": "Navigation",
                          });
                        }
                      : null,
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
                        "Navigáció",
                        style: TextStyle(
                            color: sabotage == null
                                ? Colors.white
                                : sabotage["name"] == "Navigation"
                                    ? Colors.white
                                    : Colors.grey[300],
                            fontSize: 20),
                      ),
                      const Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image(
                          image: AssetImage("assets/navigation.png"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width * .97,
                height: MediaQuery.of(context).size.height * .07,
                decoration: BoxDecoration(
                  color: widget.killEnabled ? Colors.red : Colors.grey[900],
                  borderRadius: BorderRadius.circular(7),
                ),
                child: ElevatedButton(
                  onPressed: widget.killEnabled ? () {} : null,
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
                        widget.killEnabled ? "Ölhetsz" : "Nem ölhetsz még",
                        style: TextStyle(
                            color: widget.killEnabled
                                ? Colors.white
                                : Colors.grey[300],
                            fontSize: 20),
                      ),
                      const Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image(
                          image: AssetImage("assets/impostor.png"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
