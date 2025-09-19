import 'package:flutter/material.dart';
import 'package:paracheck/pages/postflight_debrief.dart';
import 'package:paracheck/pages/flights_history.dart';
import 'package:paracheck/pages/home_page.dart';
import 'package:paracheck/pages/mfwia.dart';
import 'package:paracheck/pages/uikitdemopage.dart';
import 'package:paracheck/pages/flight_condition.dart';
import 'package:paracheck/pages/personal_weather.dart';
import 'package:paracheck/pages/radar.dart';
import 'package:paracheck/pages/breathing_stress.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/homepage': (context) => const HomePage(),
  '/uikit': (context) => const UIKitDemoPage(),
  '/flight_condition': (context) => const FlightConditionPage(),
  '/personal_weather': (context) => const PersonalWeatherPage(),
  '/mfwia': (context) => const MfwiaPage(),
  '/breathing': (context) => const BreathingStressPage(),
  '/postflight_debrief': (context) => const PostFlightDebriefPage(),
  '/radar': (context) => const RadarPage(),
  '/flights_history': (context) => const FlightsHistoryPage(),
};

/* 

Exemple d'utilisation de la navigation nommée : 

ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/flights'),
  child: const Text("Voir mes vols"),
)

*/
