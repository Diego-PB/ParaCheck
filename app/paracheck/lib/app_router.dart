import 'package:flutter/material.dart';
import 'package:paracheck/pages/post_flight_debrief.dart';
import 'package:paracheck/pages/flights_history.dart';
import 'package:paracheck/pages/home_page.dart';
import 'package:paracheck/pages/mavie.dart';
import 'package:paracheck/pages/uikitdemopage.dart';
import 'package:paracheck/pages/condition_vol.dart';
import 'package:paracheck/pages/meteo_int.dart';
import 'package:paracheck/pages/rose.dart';
import 'package:paracheck/pages/respiration_stress.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/homepage': (context) => const HomePage(),
  '/uikit': (context) => const UIKitDemoPage(),
  '/condition_vol': (context) => const ConditionVolPage(),
  '/meteo_int': (context) => const MeteoIntPage(),
  '/mavie': (context) => const MaviePage(),
  '/respiration': (context) => const RespirationStressPage(),
  '/debrief_postvol': (context) => const DebriefPostVolPage(),
  '/rose': (context) => const RosePage(),
  '/historique': (context) => const FlightsHistoryPage(),
  '/respiration_stress': (context) => RespirationStressPage(),
};

/* 

Exemple d'utilisation de la navigation nommée : 

ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/flights'),
  child: const Text("Voir mes vols"),
)

*/
