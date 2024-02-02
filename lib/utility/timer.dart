import 'package:flutter/material.dart';

class Timer extends StatefulWidget {
  const Timer({
    super.key,
    required this.duration,
    required this.textColor,
    required this.fontSize,
    required this.outerTimer,
  });

  final int duration;
  final Color textColor;
  final double fontSize;
  final bool outerTimer;

  @override
  State<Timer> createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  late int duration;
  late Color textColor;
  late double fontSize;
  bool loaded = false;
  late int seconds;
  late int minutes;
  late bool outerTimer;

  void countDown() {
    if (!outerTimer) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          duration--;
        });
        if (duration > 0) {
          countDown();
        }
      });
    }
  }

  String addZero(int number) {
    if (number < 10) {
      return "0$number";
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      duration = widget.duration;
      textColor = widget.textColor;
      fontSize = widget.fontSize;
      outerTimer = widget.outerTimer;
      countDown();
      loaded = true;
    }

    seconds = duration % 60;
    minutes = duration ~/ 60;

    return Text("${addZero(minutes)}:${addZero(seconds)}",
        style: TextStyle(color: textColor, fontSize: fontSize));
  }
}
