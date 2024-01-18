import 'package:flutter/material.dart';
import 'package:amogusvez2/pages/home.dart';

void main(){
  runApp(MaterialApp(
    routes: {
      '/': (context) => const HomePage(),
    },
  ));
}