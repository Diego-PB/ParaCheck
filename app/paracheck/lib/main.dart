import 'package:flutter/material.dart';
import 'package:paracheck/app_router.dart';
import 'pages/splash_screen.dart';
import 'package:paracheck/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParaCheck',
      home: const SplashScreen(),
      theme: buildTheme(),
      debugShowCheckedModeBanner: false,
      routes: appRoutes,
    );
  }
}