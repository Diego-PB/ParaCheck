import 'package:flutter/material.dart';

/// Types de message : succès, avertissement, attention.
enum NoticeKind { valid, warning, attention }

/// AppNotice – version simple : icône + (titre optionnel) + message.
/// Pas de boutons d’action, pas de fermeture.
class AppNotice extends StatelessWidget {
  const AppNotice({
    super.key,
    required this.kind,
    required this.message,
    this.title,
    this.compact = false,
    this.outlined = false,
  });

  final NoticeKind kind;
  final String message;
  final String? title;

  /// Réduit les paddings/tailles.
  final bool compact;

  /// Variante bordée (fond plus discret).
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final _Palette p = _palette(kind, isDark);

    final EdgeInsets pad =
        compact ? const EdgeInsets.all(10) : const EdgeInsets.all(14);

    final BoxDecoration decoration = BoxDecoration(
      color: outlined ? _tint(p.base, isDark ? 0.12 : 0.08)
                      : _tint(p.base, isDark ? 0.22 : 0.15),
      border: Border.all(
        color: outlined ? _tint(p.base, isDark ? 0.36 : 0.28)
                        : _tint(p.base, isDark ? 0.32 : 0.24),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(compact ? 10 : 12),
    );

    return Semantics(
      container: true,
      label: switch (kind) {
        NoticeKind.valid => 'Message de confirmation',
        NoticeKind.warning => 'Avertissement',
        NoticeKind.attention => 'Attention',
      },
      child: Container(
        decoration: decoration,
        padding: pad,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre d’accent
            Container(
              width: compact ? 4 : 6,
              height: compact ? 32 : 40,
              margin: EdgeInsets.only(right: compact ? 10 : 12, top: 2),
              decoration: BoxDecoration(
                color: p.base,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Icon(p.icon, size: compact ? 18 : 22, color: p.fg),
            const SizedBox(width: 10),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600, color: p.fg),
                    ),
                  if (title != null) const SizedBox(height: 2),
                  Text(
                    message,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: p.fg.withOpacity(0.95)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Palette interne minimale
class _Palette {
  const _Palette({required this.base, required this.fg, required this.icon});
  final Color base; // couleur d’accent
  final Color fg;   // couleur du texte/icône
  final IconData icon;
}

_Palette _palette(NoticeKind kind, bool isDark) {
  // Couleurs de base
  const success = Color(0xFF2E7D32);   // green 800
  const warn    = Color(0xFFB08900);   // amber-ish
  const alert   = Color(0xFFEF6C00);   // orange 800

  switch (kind) {
    case NoticeKind.valid:
      return _Palette(
        base: success,
        fg: isDark ? Colors.greenAccent.shade100 : Colors.green.shade900,
        icon: Icons.check_circle_rounded,
      );
    case NoticeKind.warning:
      return _Palette(
        base: warn,
        fg: isDark ? Colors.amber.shade100 : const Color(0xFF4E3A00),
        icon: Icons.warning_amber_rounded,
      );
    case NoticeKind.attention:
      return _Palette(
        base: alert,
        fg: isDark ? Colors.orange.shade100 : const Color(0xFF5A2E00),
        icon: Icons.priority_high_rounded,
      );
  }
}

Color _tint(Color base, double opacity) =>
    base.withOpacity(opacity.clamp(0.0, 1.0));
