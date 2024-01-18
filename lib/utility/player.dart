import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({super.key, required this.color, required this.name});

  final Color color;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ColorFiltered(
                colorFilter: ColorFilter.mode(
                    color,
                    BlendMode.modulate
                ),
                child: Image.asset("assets/player.png",
                  width: MediaQuery.of(context).size.width * .25,
                )
            ),
            Text(name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20
              )
            )
          ],
        ),
      ),
    );
  }
}