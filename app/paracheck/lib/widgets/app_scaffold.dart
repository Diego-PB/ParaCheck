import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:paracheck/widgets/bottom_bubble_nav.dart';

class AppScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final Widget? fab;
  final String logoPath;
  final bool showReturnButton;
  final VoidCallback? onReturn;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.fab,
    this.logoPath = 'assets/Paracheck_logo.png',
    this.showReturnButton = false,
    this.onReturn,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _open = false;

  List<NavAction> _fixedActions(BuildContext context) => [
    NavAction(label: 'Accueil', icon: Icons.home, onTap: () => {
      Navigator.pushNamed(context, '/homepage'),
    }),
<<<<<<< HEAD
    NavAction(label: 'Pré-vol', icon: Icons.checklist, onTap: () => {
      Navigator.pushNamed(context, '/condition_vol'),
=======
    NavAction(label: 'Historique', icon: Icons.flight, onTap: () => {
      Navigator.pushNamed(context, '/flights_history'),
>>>>>>> 32-consultation-historique-données-de-vol
    }),
    NavAction(label: 'Post-vol', icon: Icons.paragliding, onTap: () => {
      Navigator.pushNamed(context, '/debrief_postvol'),
    }),
    NavAction(label: 'Historiques', icon: Icons.history, onTap: () => {
      Navigator.pushNamed(context, '/history'),
    }),
    NavAction(label: 'Paramètres', icon: Icons.settings, onTap: () => {
      Navigator.pushNamed(context, '/settings'),
    }),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Jamais de flèche système
        leading: widget.showReturnButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Retour',
                onPressed: widget.onReturn,
              )
            : null,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
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
