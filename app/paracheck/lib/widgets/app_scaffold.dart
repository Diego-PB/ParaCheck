import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? fab;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.fab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(16.0), child: body)),
      floatingActionButton: fab,
    );
  }
}
