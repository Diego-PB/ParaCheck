import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:paracheck/design/shadows.dart';

// Action pour chaque bulle
class NavAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const NavAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

// Dock en bulles éclatées autour du bouton logo
class BubbleDock extends StatelessWidget {
  final bool isOpen;
  final List<NavAction> actions;
  final String logoPath;
  final VoidCallback onLogoTap;

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
          // Bulles éclatées
          for (int i = 0; i < actions.length; i++)
            _BubbleItem(
              isOpen: isOpen,
              index: i,
              total: actions.length,
              action: actions[i],
            ),

          // Bouton logo central avec bandeau horizontal
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                // Le bandeau collé en bas
                Container(
                  height: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),

                // Le logo rond qui dépasse
                Positioned(
                  top: -28, // Moitié de sa hauteur pour qu'il dépasse
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

/// Bulle individuelle animée
class _BubbleItem extends StatelessWidget {
  final bool isOpen;
  final int index;
  final int total;
  final NavAction action;

  const _BubbleItem({
    required this.isOpen,
    required this.index,
    required this.total,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    // Arc d’affichage
    const startDeg = 180.0;
    const endDeg = 360.0;
    final step = total <= 1 ? 0.0 : (endDeg - startDeg) / (total - 1);
    final angleDeg = startDeg + step * index;
    final angle = angleDeg * math.pi / 180.0;

    // Taille + espacement + hauteur
    final size = 60.0 + (index * 5 % 15);
    final spread = 0.65 + ((index.isEven ? 1 : -1) * 0.05);
    final lift = 1.2;

    // Coordonnées d’Alignment
    final x = math.cos(angle) * spread;
    final y = 0 - (lift * (math.sin(angle).abs()));

    final target = Alignment(x, y);
    const closed = Alignment(0, 1);

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

// Bouton bulle cliquable
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
            border: Border.all(color: scheme.primary.withValues(), width: 2),
          ),
          child: Center(
            child: Icon(action.icon, size: 18, color: scheme.primary),
          ),
        ),
      ),
    );
  }
}
