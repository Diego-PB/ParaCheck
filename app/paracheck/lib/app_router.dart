import 'package:flutter/material.dart';
import 'package:paracheck/pages/home_page.dart';
import 'package:paracheck/pages/uikitdemopage.dart';
import 'package:paracheck/pages/condition_vol.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/homepage': (context) => const HomePage(),
  '/uikit': (context) => const UIKitDemoPage(),
  '/conditions_vol': (context) => const ConditionVolPage(),
};

/* 

Exemple d'utilisation de la navigation nommée : 

ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/flights'),
  child: const Text("Voir mes vols"),
)

*/
