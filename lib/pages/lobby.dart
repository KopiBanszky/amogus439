import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utility/types.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  late dynamic arguments;
  late List<Player> players;
  
  if(arguments["host"]){

  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text("Amogusvez"),
            Text("ID: 123456")
          ],
        )
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Lobby"),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/game');
              },
              child: const Text("Start Game"),
            ),
          ],
        ),
      ),
    );
  }
}
