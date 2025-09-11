import 'package:flutter/material.dart';
import 'package:paracheck/pages/home_page.dart';
import 'package:paracheck/pages/uikitdemopage.dart';
import 'package:paracheck/pages/condition_vol.dart';
import 'package:paracheck/pages/meteo_int.dart';
import 'package:paracheck/pages/debrief_postvol.dart';
import 'package:paracheck/pages/rose.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/homepage': (context) => const HomePage(),
  '/uikit': (context) => const UIKitDemoPage(),
  '/conditions_vol': (context) => const ConditionVolPage(),
  '/meteo_int': (context) => const MeteoIntPage(),
  '/debrief_postvol': (context) => const DebriefPostVolPage(),
  '/rose': (context) => const RosePage(),
};

/* 

Exemple d'utilisation de la navigation nommée : 

ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/flights'),
  child: const Text("Voir mes vols"),
)

*/
