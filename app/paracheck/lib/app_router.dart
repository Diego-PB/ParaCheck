import 'package:flutter/material.dart';
import 'package:paracheck/main.dart';
import 'package:paracheck/pages/uikitdemopage.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const MyHomePage(title: 'Paracheck Home Page'),
  '/uikit': (context) => const UIKitDemoPage(),
};

/* 

Exemple d'utilisation de la navigation nommée : 

ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/flights'),
  child: const Text("Voir mes vols"),
)

*/
