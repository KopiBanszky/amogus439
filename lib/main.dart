import 'package:amogusvez2/pages/GameMain.dart';
import 'package:amogusvez2/pages/Voting.dart';
import 'package:amogusvez2/pages/Waiting.dart';
import 'package:amogusvez2/pages/lobby.dart';
import 'package:amogusvez2/pages/qr_reader.dart';
import 'package:amogusvez2/pages/roleReveal.dart';
import 'package:amogusvez2/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:amogusvez2/pages/home.dart';

void main() {
  runApp(MaterialApp(
    routes: {
      '/': (context) => const HomePage(),
      '/lobby': (context) => const LobbyPage(),
      '/settings': (context) => const SettingsPage(),
      '/roleReveal': (context) => const RoleRevealPage(),
      '/gameMain': (context) => const GameMainPage(),
      '/qrReader': (context) => const SrReaderPage(),
      '/waitingForVote': (context) => const WaitingPage(),
      '/voting': (context) => const VotingPage(),
    },
  ));
}
