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
  bool tapped = false;

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments;
    if(!loaded){
      plyr = arguments['player'];
      gameId = arguments['gameId'];
      host = arguments['host'];
      name_role = plyr.name;
      loaded = true;
    }

    return Scaffold(
      body: ElevatedButton(
        onPressed: () {
          if(!tapped) {
            setState(() {
              tapped = true;
              name_role = "${plyr.team ? "Impostor" : "Crewmate"} ${plyr.name}";
            });
          }
        },
        child: Center(
          child: Column(
            children: [
              Image.asset("assets/background.png"),
              PlayerWidget(
                  color: plyr.color,
                  name: plyr.name
              ),
              Text(!tapped ?
                  "Kattints a képernyőre a szereped felfedéséhez!" :
                  "Te $name_role vagy! Kattints a képernyőre a folytatáshoz!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20
                  )
              ),
            ],
          )
        ),
      ),
    );
  }
}
