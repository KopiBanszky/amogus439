import 'package:amogusvez2/utility/player.dart';
import 'package:amogusvez2/utility/types.dart';
import 'package:flutter/material.dart';

class VotedOutPage extends StatefulWidget {
  const VotedOutPage({super.key});

  @override
  State<VotedOutPage> createState() => _VotedOutPageState();
}

class _VotedOutPageState extends State<VotedOutPage> {
  bool loaded = false;
  dynamic arguments;

  late bool skip; //true if the player skipped the vote, false if not
  late Player votedOut; //the player who got voted out

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      arguments = ModalRoute.of(context)!.settings.arguments;
      skip = arguments["skip"];
      if (!skip) votedOut = arguments["votedOut"];
      loaded = true;
    }

    return Scaffold(
        backgroundColor: Colors.grey[900],
        body: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              "votedOut": votedOut,
              "skip": skip,
            });
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${skip ? "Senki nem" : votedOut.name} lett kiszavazva!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
                if (!skip)
                  const SizedBox(
                    height: 20,
                  ),
                if (!skip)
                  PlayerWidget(
                      color: votedOut.color,
                      name: votedOut.name,
                      img: imgType.dead),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Kattints a képernyőre a folytatáshoz!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
