/*
  This file defines the routing table for the ParaCheck Flutter application.
  It maps route names (strings) to the corresponding page widget builders,
  allowing navigation throughout the app using named routes.
  This approach centralizes route management for simplicity and maintainability.
*/

import 'package:flutter/material.dart';
import 'package:paracheck/pages/postflight_debrief.dart';
import 'package:paracheck/pages/flights_history.dart';
import 'package:paracheck/pages/home_page.dart';
import 'package:paracheck/pages/mavie.dart';
import 'package:paracheck/pages/uikitdemopage.dart';
import 'package:paracheck/pages/flight_condition.dart';
import 'package:paracheck/pages/personal_weather.dart';
import 'package:paracheck/pages/radar_page.dart';
import 'package:paracheck/pages/breathing_stress.dart';
import 'package:paracheck/pages/settings.dart';
import 'package:paracheck/pages/manage_sites.dart';

final Map<String, WidgetBuilder> appRoutes = {
  // Home page of the application
  '/homepage': (context) => const HomePage(),

  // Demo UI kit page for testing or showcasing UI components
  '/uikit': (context) => const UIKitDemoPage(),

  // Flight condition display page
  '/flight_condition': (context) => const FlightConditionPage(),

  // Personal weather page
  '/personal_weather': (context) => const PersonalWeatherPage(),

  // MAVIE questionnaire page
  '/mavie': (context) => const MaviePage(),

  // Breathing stress info page
  '/breathing': (context) => const BreathingStressPage(),

  // Post-flight debriefing page
  '/postflight_debrief': (context) => const PostFlightDebriefPage(),

  // Radar display page expects an argument 'flightId' passed via route settings
  '/radar': (context) {
    // Extract flightId parameter safely from route arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final flightId = (args?['flightId'] as String?) ?? '';
    return RadarPage(flightId: flightId);
  },

  // History of flights page
  '/flights_history': (context) => const FlightsHistoryPage(),

  // Settings page
  '/settings': (context) => const SettingsPage(),
  '/manage_sites': (context) => const ManageSitesPage(),
};
