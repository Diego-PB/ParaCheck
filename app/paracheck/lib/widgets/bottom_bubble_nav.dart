/*
 BubbleDock is a widget displaying a central circular logo button with multiple "bubbles"
 (navigation actions) that expand around it in a semi-circular arc when opened.
 Each bubble is clickable and represents a navigation action.
 This provides a visually appealing, space-efficient navigation dock used in ParaCheck.
*/

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:paracheck/design/shadows.dart';

// Navigation action for each bubble
class NavAction {
  final String label;       // Label displayed for this action
  final IconData icon;      // Icon to represent the action
  final VoidCallback onTap; // Callback on tap (usually navigation)

  const NavAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

// Dock showing bubbles expanded around a central logo button
class BubbleDock extends StatelessWidget {
  final bool isOpen;              // Whether the dock is open (bubbles visible)
  final List<NavAction> actions; // List of actions to display as bubbles
  final String logoPath;          // Asset path for the central logo image
  final VoidCallback onLogoTap;  // Callback when central logo is tapped (toggles open state)

  const BubbleDock({
    super.key,
    required this.isOpen,
    required this.actions,
    required this.logoPath,
    required this.onLogoTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Render each navigation bubble around the logo
          for (int i = 0; i < actions.length; i++)
            _BubbleItem(
              isOpen: isOpen,
              index: i,
              total: actions.length,
              action: actions[i],
            ),

          // Central bottom horizontal bar and logo button above it
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                // Bottom horizontal bar behind bubbles and logo
                Container(
                  height: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),

                // Circular logo button, positioned half above the bar
                Positioned(
                  top: -28,
                  child: GestureDetector(
                    onTap: onLogoTap,
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
                        boxShadow: AppShadows.soft,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: ClipOval(
                          child: Image.asset(logoPath, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Individual animated bubble item displayed around the dock's central logo
class _BubbleItem extends StatelessWidget {
  final bool isOpen;    // Whether the dock is open (bubbles visible)
  final int index;      // Position index of this bubble
  final int total;      // Total number of bubbles
  final NavAction action;

  const _BubbleItem({
    required this.isOpen,
    required this.index,
    required this.total,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    // Define the arc from 180° to 360° (bottom semi-circle)
    const startDeg = 180.0;
    const endDeg = 360.0;
    final step = total <= 1 ? 0.0 : (endDeg - startDeg) / (total - 1);
    final angleDeg = startDeg + step * index;
    final angle = angleDeg * math.pi / 180.0;

    // Bubble size varies slightly for some visual interest
    final size = 60.0 + (index * 5 % 15);

    // Spread factor controls how far from center horizontally (with slight variation)
    final spread = 0.65 + ((index.isEven ? 1 : -1) * 0.05);

    // Lift controls vertical displacement upwards
    final lift = 1.2;

    // Calculate alignment coordinates for bubble around circle arc
    final x = math.cos(angle) * spread;
    final y = 0 - (lift * (math.sin(angle).abs()));

    final target = Alignment(x, y);
    const closed = Alignment(0, 1); // Position when dock is closed (bottom center)

    return AnimatedAlign(
      alignment: isOpen ? target : closed,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: isOpen ? 1 : 0,
        duration: const Duration(milliseconds: 220),
        child: SizedBox(
          width: size,
          height: size,
          child: _BubbleButton(action: action),
        ),
      ),
    );
  }
}

// Clickable bubble button widget representing a navigation action
class _BubbleButton extends StatelessWidget {
  final NavAction action;
  const _BubbleButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: action.onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: scheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: scheme.primary.withValues(alpha: 1), width: 2),
          ),
          child: Center(
            child: Icon(action.icon, size: 18, color: scheme.primary),
          ),
        ),
      ),
    );
  }
}
