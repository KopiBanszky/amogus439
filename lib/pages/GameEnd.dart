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
    double section = MediaQuery.of(context).size.width / players.length;
    for (var i = 0; i < players.length; i++) {
      list.add(Positioned(
        left: section * .5 * i,
        width: section,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(players[i].color, BlendMode.modulate),
          child: const Image(
            image: AssetImage("assets/player.png"),
          ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              winner ? "Crewmates Win" : "Impostors Win",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            Stack(
              children: _buildPlayers(players),
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
