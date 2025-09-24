/*
 AppScaffold is a reusable scaffold widget that provides a consistent app layout structure.
 It includes an AppBar with customizable title and optional return button,
 a body area for main content, an optional floating action button,
 and a custom bottom navigation bar with a "bubble" style dock that toggles open/closed.
 The bottom navigation bar contains fixed quick-access actions to key pages,
 displayed as tappable bubbles above a blurred dark overlay when open.
*/

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:paracheck/widgets/bottom_bubble_nav.dart';

class AppScaffold extends StatefulWidget {
  final String title;           // Title shown in the AppBar
  final Widget body;            // Main page content
  final Widget? fab;            // Optional floating action button
  final String logoPath;        // Asset path for logo in bottom nav toggle
  final bool showReturnButton;  // Whether to show a back arrow in the AppBar
  final VoidCallback? onReturn; // Callback when the back arrow is pressed

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
  bool _open = false; // Controls if the bottom bubble dock is expanded

  // Defines the fixed navigation actions available in the bubble dock
  List<NavAction> _fixedActions(BuildContext context) => [
    NavAction(
      label: 'Pré-vol',
      icon: Icons.checklist,
      onTap: () => {Navigator.pushNamed(context, '/personal_weather')},
    ),
    NavAction(
      label: 'Post-vol',
      icon: Icons.paragliding,
      onTap: () => {Navigator.pushNamed(context, '/postflight_debrief')},
    ),
    NavAction(
      label: 'Accueil',
      icon: Icons.home,
      onTap: () => {Navigator.pushNamed(context, '/homepage')},
    ),
    NavAction(
      label: 'Historique',
      icon: Icons.history,
      onTap: () => {Navigator.pushNamed(context, '/flights_history')},
    ),
    NavAction(
      label: 'Paramètres',
      icon: Icons.settings,
      onTap: () => {Navigator.pushNamed(context, '/settings')},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Never show default system back arrow
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
          // Main content area with padding inside SafeArea
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: widget.body,
            ),
          ),

          // Overlay for bubble dock; only interactive when open
          IgnorePointer(
            ignoring: !_open,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _open ? 1 : 0,
              child: Stack(
                children: [
                  // Background blur and translucent black veil
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.2), // subtle veil
                      ),
                    ),
                  ),

                  // Bubble dock aligned at bottom center
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

      // Bottom navigation bar area with a toggleable logo bubble overlay
      bottomNavigationBar: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Bottom color bar matching primary theme color
          Container(height: 64, color: Theme.of(context).colorScheme.primary),

          // Positioned circular logo bubble, toggles the bubble dock when tapped
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
