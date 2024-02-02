// ignore_for_file: must_be_immutable, camel_case_types

import 'package:flutter/material.dart';

enum imgType { player, impostor, dead, emergency, report }

class PlayerWidget extends StatelessWidget {
  PlayerWidget(
      {super.key, required this.color, required this.name, required this.img});

  final Color color;
  final String name;
  final imgType img;
  late String imgPath;

  @override
  Widget build(BuildContext context) {
    switch (img) {
      case imgType.impostor:
        imgPath = "impostor.png";
        break;
      case imgType.dead:
        imgPath = "dead.png";
        break;
      case imgType.emergency:
        imgPath = "caller.png";
        break;
      case imgType.report:
        imgPath = "reporter.png";
        break;
      default:
        imgPath = "player.png";
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ColorFiltered(
                colorFilter: ColorFilter.mode(color, BlendMode.modulate),
                child: Image.asset(
                  "assets/$imgPath",
                  width: MediaQuery.of(context).size.width * .25,
                )),
            Text(name,
                style: const TextStyle(color: Colors.white, fontSize: 20))
          ],
        ),
      ),
    );
  }
}
