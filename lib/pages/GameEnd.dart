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
    double plyrWidth =
        MediaQuery.of(context).size.width / (players.length ~/ 2);

    for (var i = 0; i < players.length; i += 2) {
      list.add(Positioned(
        top: (i / 2) * 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColorFiltered(
              colorFilter:
                  ColorFilter.mode(players[i].color, BlendMode.modulate),
              child: Image(
                image: const AssetImage("assets/player.png"),
                width: plyrWidth,
              ),
            ),
            SizedBox(
              width: plyrWidth * (i / 2),
            ),
            ColorFiltered(
              colorFilter:
                  ColorFilter.mode(players[i + 1].color, BlendMode.modulate),
              child: Image(
                image: const AssetImage("assets/player.png"),
                width: plyrWidth,
              ),
            ),
          ],
        ),
      ));
    }
    list = list.reversed.toList();
    if (players.length % 2 == 1) {
      list.add(Positioned(
        top: -50,
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
    }
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
                children: _buildPlayers(players),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              child: const Text("Back to Home"),
            ),
          ],
        ));
  }
}
