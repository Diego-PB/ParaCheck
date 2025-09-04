import 'package:flutter/material.dart';
import 'package:paracheck/main.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const MyHomePage(title: 'Paracheck Home Page'),
};

/* 

Exemple d'utilisation de la navigation nommée : 

ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/flights'),
  child: const Text("Voir mes vols"),
)

*/
