import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:paracheck/widgets/bottom_bubble_nav.dart';

class AppScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final Widget? fab;
  final String logoPath;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.fab,
    this.logoPath = 'lib/assets/Paracheck_logo.png',
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _open = false;

  List<NavAction> _fixedActions(BuildContext context) => [
    NavAction(label: 'Accueil', icon: Icons.home, onTap: () {}),
    NavAction(label: 'Vols', icon: Icons.flight, onTap: () {}),
    NavAction(label: 'Checklist', icon: Icons.checklist, onTap: () {}),
    NavAction(label: 'Statistiques', icon: Icons.query_stats, onTap: () {}),
    NavAction(label: 'Paramètres', icon: Icons.settings, onTap: () {}),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Permet à l'overlay de passer sous la bottom bar
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          // Contenu
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: widget.body,
            ),
          ),

          // Overlay bulles (au-dessus du contenu, collé en bas)
          // On le rend cliquable uniquement quand _open = true
          IgnorePointer(
            ignoring: !_open,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _open ? 1 : 0,
              child: Stack(
                children: [
                  // Flou + voile semi-transparent
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.2), // voile optionnel
                      ),
                    ),
                  ),

                  // Bulles
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: BubbleDock(
                      isOpen: _open,
                      logoPath: widget.logoPath,
                      onLogoTap: () => setState(() => _open = !_open),
                      actions: _fixedActions(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: widget.fab,

      // BOTTOM BAR = bandeau + logo (toggle)
      bottomNavigationBar: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(height: 64, color: Theme.of(context).colorScheme.primary),
          Positioned(
            top: -28,
            child: GestureDetector(
              onTap: () => setState(() => _open = !_open),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: ClipOval(
                    child: Image.asset(widget.logoPath, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
