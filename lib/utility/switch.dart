import 'dart:math';

import 'package:flutter/material.dart';

class SwitchWidget extends StatelessWidget {
  const SwitchWidget({super.key, required this.trunOn, required this.column});

  final bool trunOn;
  final bool column;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: column
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform:
                      trunOn ? Matrix4.rotationX(pi) : Matrix4.rotationX(0),
                  child: const Image(
                    image: AssetImage("assets/switch.png"),
                  ),
                ),
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      trunOn
                          ? const Color.fromARGB(255, 2, 160, 7)
                          : const Color.fromARGB(255, 255, 17, 0),
                      BlendMode.modulate),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image(
                      image: AssetImage("assets/light.png"),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: trunOn
                      ? Matrix4.rotationX(pi * 1.5)
                      : Matrix4.rotationX(pi / 2),
                  child: const Image(
                    image: AssetImage("assets/switch.png"),
                  ),
                ),
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      trunOn
                          ? const Color.fromARGB(255, 2, 160, 7)
                          : const Color.fromARGB(255, 255, 17, 0),
                      BlendMode.modulate),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image(
                      image: AssetImage("assets/light.png"),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
