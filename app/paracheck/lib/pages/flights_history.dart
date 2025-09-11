import 'package:flutter/material.dart';
import 'package:paracheck/widgets/app_scaffold.dart';

class FlightsHistoryPage extends StatelessWidget {
  const FlightsHistoryPage({super.key});

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