import 'package:flutter/material.dart';
import 'package:paracheck/pages/postflight_debrief.dart';
import 'package:paracheck/pages/flights_history.dart';
import 'package:paracheck/pages/home_page.dart';
import 'package:paracheck/pages/mavie.dart';
import 'package:paracheck/pages/settings.dart';
import 'package:paracheck/pages/uikitdemopage.dart';
import 'package:paracheck/pages/flight_condition.dart';
import 'package:paracheck/pages/personal_weather.dart';
import 'package:paracheck/pages/radar_page.dart';
import 'package:paracheck/pages/breathing_stress.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/homepage': (context) => const HomePage(),
  '/uikit': (context) => const UIKitDemoPage(),
  '/flight_condition': (context) => const FlightConditionPage(),
  '/personal_weather': (context) => const PersonalWeatherPage(),
  '/mavie': (context) => const MaviePage(),
  '/breathing': (context) => const BreathingStressPage(),
  '/postflight_debrief': (context) => const PostFlightDebriefPage(),
  '/radar': (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final flightId = (args?['flightId'] as String?) ?? '';
    return RadarPage(flightId: flightId);
  },
  '/flights_history': (context) => const FlightsHistoryPage(),
  '/settings': (context) => const SettingsPage(),
};

/* 

Exemple d'utilisation de la navigation nommée : 

ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/flights'),
  child: const Text("Voir mes vols"),
)

*/
