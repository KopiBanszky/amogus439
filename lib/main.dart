import 'package:amogusvez2/pages/lobby.dart';
import 'package:amogusvez2/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:amogusvez2/pages/home.dart';

void main(){
  runApp(MaterialApp(
    routes: {
      '/': (context) => const HomePage(),
      '/lobby': (context) => const LobbyPage(),
      '/settings': (context) => const SettingsPage(),
    },
  ));
}

