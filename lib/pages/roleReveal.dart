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
      backgroundColor: Colors.grey[900],
      body: ElevatedButton(
        onPressed: () {
          if(!tapped) {
            setState(() {
              tapped = true;
              name_role = "${plyr.name} - ${plyr.team ? "Impostor" : "Crewmate"}";
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
              PlayerWidget(
                  color: plyr.color,
                  name: name_role
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
