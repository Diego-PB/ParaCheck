import 'package:flutter/material.dart';
import 'package:paracheck/app_router.dart';

import 'pages/splash_screen.dart';
import 'package:paracheck/pages/uikitdemopage.dart';
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
      title: 'Paracheck',
      home: const SplashScreen(),
      theme: buildTheme(),
      debugShowCheckedModeBanner: false,
      routes: appRoutes,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[const Text('Hello World!')],
        ),
      ),
    );
  }
}
