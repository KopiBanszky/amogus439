import 'dart:math';

import 'package:amogusvez2/utility/alert.dart';
import 'package:amogusvez2/utility/stLessTimer.dart';
import 'package:amogusvez2/utility/switch.dart';
import 'package:amogusvez2/utility/types.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class NavigationMinigame extends StatefulWidget {
  const NavigationMinigame({super.key});

  @override
  State<NavigationMinigame> createState() => _NavigationMinigameState();
}

bool AND(bool a, bool b, bool not) {
  return not ? !(a && b) : a && b;
}

bool OR(bool a, bool b, bool not) {
  return not ? !(a || b) : a || b;
}

bool XOR(bool a, bool b, bool not) {
  return not ? !(a ^ b) : a ^ b;
}

final int timeDef = 4;

class _NavigationMinigameState extends State<NavigationMinigame> {
  dynamic arguments;
  late Player plyr;
  late Socket socket;
  late String gameId;
  dynamic sabotage;

  bool on = false;

  List<bool> switches = [false, false, false, false];

  List<Function> functions = [AND, OR, XOR];

  List<int> randFuncs = [];
  List<bool> not = [];

  List<String> gates = ["AND", "OR", "XOR"];

  int time = timeDef;

  bool light() {
    bool a = switches[0];
    bool b = switches[1];
    bool c = switches[2];
    bool d = switches[3];

    bool f1 = functions[randFuncs[0]](a, b, not[0]);
    bool f2 = functions[randFuncs[1]](c, d, not[1]);
    bool f3 = functions[randFuncs[2]](f1, f2, not[2]);

    return f3;
  }

  void generateTask() {
    randFuncs.clear();
    not.clear();
    for (int i = 0; i < 3; i++) {
      randFuncs.add((Random().nextInt(functions.length).toInt()));
      not.add((Random().nextInt(2) == 0));
    }
  }

  void _displayTask() {
    gates.clear();
    for (int i = 0; i < 3; i++) {
      if (randFuncs[i] == 0) {
        gates.add(not[i] ? "NAND" : "AND");
      } else if (randFuncs[i] == 1) {
        gates.add(not[i] ? "NOR" : "OR");
      } else {
        gates.add(not[i] ? "XNOR" : "XOR");
      }
    }
    setState(() {
      on = light();
    });
  }

  void tryFix() {
    if (light()) {
      showAlert("Hiba", "A kapcsolók még mindig rosszul vannak állítva!",
          Colors.red, true, () {}, "Ok", false, () {}, "", context);
    } else {
      socket.emit("fix_simple", {
        "game_id": gameId,
        "user_id": plyr.id,
        "sabotage_id": sabotage["game_sb_id"],
        "name": "Navigation"
      });

      time = 3;
      timer();
      Future.delayed(const Duration(seconds: 4), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  void initState() {
    socket = arguments["socket"];
    generateTask();
    while (light()) {
      generateTask();
    }

    _displayTask();
    timer();

    socket.on("fix_simple", (data) {
      if (data["code"] != 200) {
        showAlert("Hiba - ${data["code"]}", data["message"], Colors.red, true,
            () {}, "Ok", false, () {}, "", context);
      }
    });

    super.initState();
  }

  void timer() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        time--;
      });
      if (time > 0) {
        timer();
      }
      if (time == 0) on = light();
    });
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)?.settings.arguments;
    plyr = arguments["player"];
    gameId = arguments["gameId"];
    sabotage = arguments["sabotage"];

    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Navigation",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              StLessTimer(
                  duration: time, textColor: Colors.white, fontSize: 20),
            ],
          ),
          backgroundColor: Colors.grey[900],
        ),
        backgroundColor: Colors.grey[900],
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .1,
              width: MediaQuery.of(context).size.width * .2,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ColorFiltered(
                        colorFilter: on
                            ? const ColorFilter.mode(
                                Colors.yellow, BlendMode.modulate)
                            : const ColorFilter.mode(
                                Colors.grey, BlendMode.modulate),
                        child: const Image(
                          image: AssetImage('assets/light.png'),
                        ),
                      ),
                    ),
                  ]),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .7,
              width: MediaQuery.of(context).size.width * 1,
              child: Stack(
                children: [
                  Positioned(
                    bottom:
                        MediaQuery.of(context).size.height * .015, //.1 vagy .3
                    left: MediaQuery.of(context).size.width * .06,
                    height: MediaQuery.of(context).size.width * .46,
                    child: Image(
                      image: AssetImage("assets/${gates[0]}.png"),
                    ),
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).size.height *
                        .013, //.45 vagy .65
                    right: MediaQuery.of(context).size.width * .036,
                    height: MediaQuery.of(context).size.width * .47,
                    child: Image(
                      image: AssetImage("assets/${gates[1]}.png"),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height *
                        .07, //.3 vagy .43 vagy .1 vagy .65
                    left: MediaQuery.of(context).size.width * .3,
                    height: MediaQuery.of(context).size.width * .47,
                    child: Image(
                      image: AssetImage("assets/${gates[2]}.png"),
                    ),
                  ),
                  Positioned(
                    // top: MediaQuery.of(context).size.height * -.1, //.1 vagy .3
                    // left: MediaQuery.of(context).size.width * -.2,
                    left: 0,
                    top: MediaQuery.of(context).size.height * -.195,
                    width: MediaQuery.of(context).size.width * 1,
                    child: const Image(
                      image: AssetImage("assets/bg.png"),
                    ),
                  ),
                ],
              ),
            ),
            //switches
            SizedBox(
              height: MediaQuery.of(context).size.height * .1,
              width: MediaQuery.of(context).size.width * 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .2,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          switches[0] = !switches[0];
                          if (time == 0) timer();
                          time = timeDef;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: SwitchWidget(trunOn: switches[0], column: true),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .2,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          switches[1] = !switches[1];
                          if (time == 0) timer();
                          time = timeDef;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: SwitchWidget(trunOn: switches[1], column: true),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .2,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          switches[2] = !switches[2];
                          if (time == 0) timer();
                          time = timeDef;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: SwitchWidget(trunOn: switches[2], column: true),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .2,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          switches[3] = !switches[3];
                          if (time == 0) timer();
                          time = timeDef;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: SwitchWidget(trunOn: switches[3], column: true),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
