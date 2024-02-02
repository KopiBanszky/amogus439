// ignore_for_file: must_be_immutable, file_names

import 'package:flutter/material.dart';

class StLessTimer extends StatelessWidget {
  StLessTimer({
    super.key,
    required this.duration,
    required this.textColor,
    required this.fontSize,
  });

  final int duration;
  final Color textColor;
  final double fontSize;

  late int minutes;
  late int seconds;

  String addZero(int number) {
    if (number < 10) {
      return "0$number";
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    minutes = duration ~/ 60;
    seconds = duration % 60;

    return Text("${addZero(minutes)}:${addZero(seconds)}",
        style: TextStyle(color: textColor, fontSize: fontSize));
  }
}
