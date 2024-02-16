import 'package:amogusvez2/utility/types.dart';
import 'package:flutter/material.dart';

class GameEndPage extends StatefulWidget {
  const GameEndPage({super.key});

  @override
  State<GameEndPage> createState() => _GameEndPageState();
}

class _GameEndPageState extends State<GameEndPage> {
  dynamic arguments;
  late Player plyr;
  List<Player> players = [];
  List<Player> impostors = [];
  late bool winner;

  List<Widget> _buildPlayers(List<Player> players) {
    List<Widget> list = [];
    final int maxWidth = players.length > 5 ? players.length : 5;
    double plyrWidth =
        MediaQuery.of(context).size.width / (maxWidth ~/ 1.5);

    for (var i = 0; i < players.length - 1; i += 2) {
      list.add(Positioned(
        top: (i / 2) * -10.0 + 50,
        // left: (i/2) * plyrWidth *.5,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColorFiltered(
              colorFilter:
                  ColorFilter.mode(players[i].color, BlendMode.modulate),
              child: Image(
                image: const AssetImage("assets/player.png"),
                width: plyrWidth - (plyrWidth * (i / 2) * .06),
              ),
            ),
            SizedBox(
              width: plyrWidth * (i / 2) +
                  ((players.length % 2 == 1) || (i + 1 != players.length - 1)
                      ? 0
                      : plyrWidth * .6),
              child: Text(
                i.toString(),
                style: TextStyle(color: Colors.white),
              ),
            ),
            if ((players.length % 2 == 1) || (i + 1 != players.length - 1))
              ColorFiltered(
                colorFilter:
                    ColorFilter.mode(players[i + 1].color, BlendMode.modulate),
                child: Image(
                  image: const AssetImage("assets/player.png"),
                  width: plyrWidth - (plyrWidth * (i / 2) * .06),
                ),
              ),
          ],
        ),
      ));
    }
    list = list.reversed.toList();
    list.add(Positioned(
      top: 10 + 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
                players[players.length - 1].color, BlendMode.modulate),
            child: Image(
              image: const AssetImage("assets/player.png"),
              width: plyrWidth,
            ),
          ),
        ],
      ),
    ));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments;
    plyr = arguments['player'];
    players = arguments['players'];
    impostors = arguments['impostors'];
    winner = arguments['winner'];

    return Scaffold(
        backgroundColor: Colors.grey[900],
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              winner ? "Crewmates Win" : "Impostors Win",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * .5,
              child: Stack(
                alignment: Alignment.center,
                children: _buildPlayers(winner ? players : impostors),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.restorablePushNamed(context, '/');
              },
              child: const Text("Back to Home"),
            ),
          ],
        ));
  }
}
