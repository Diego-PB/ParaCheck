import 'package:flutter/material.dart';
import 'package:paracheck/widgets/app_scaffold.dart';

class FlightsHistoryPage extends StatefulWidget {
  const FlightsHistoryPage({super.key});

  @override
  State<FlightsHistoryPage> createState() => _FlightsHistoryPageState();
}

class _FlightsHistoryPageState extends State<FlightsHistoryPage> {

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Historique des vols',
      body: Center(
        child: Text('Historique des vols'),
      ),
    );
  }
}