/*
 A reusable Flutter widget to display different types of notices to the user,
 such as success confirmations, warnings, or attention alerts.
 The widget shows an icon, an optional title, and a message with customizable styles,
 adapting automatically to light/dark themes and offering compact and outlined variants.
*/

import 'package:flutter/material.dart';

// Notice kinds: success, warning, attention.
enum NoticeKind { valid, warning, attention }

// AppNotice – simple version: icon + (optional title) + message.
// No action buttons, no close functionality.
class AppNotice extends StatelessWidget {
  const AppNotice({
    super.key,
    required this.kind,
    required this.message,
    this.title,
    this.compact = false,
    this.outlined = false,
  });

  // Type of the notice (success, warning, attention)
  final NoticeKind kind;

  // Main message text to display
  final String message;

  // Optional title displayed above the message
  final String? title;

  // If true, reduces padding and sizes for a compact display
  final bool compact;

  // If true, applies an outlined variant with a more subtle background
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final _Palette p = _palette(kind, isDark);

    // Padding varies depending on compact mode
    final EdgeInsets pad =
        compact ? const EdgeInsets.all(10) : const EdgeInsets.all(14);

    // Box decoration: background color and border determined by kind and variants
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
        NoticeKind.valid => 'Confirmation message',
        NoticeKind.warning => 'Warning',
        NoticeKind.attention => 'Attention',
      },
      child: Container(
        decoration: decoration,
        padding: pad,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accent bar on left side
            Container(
              width: compact ? 4 : 6,
              height: compact ? 32 : 40,
              margin: EdgeInsets.only(right: compact ? 10 : 12, top: 2),
              decoration: BoxDecoration(
                color: p.base,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            // Icon representing the notice type
            Icon(p.icon, size: compact ? 18 : 22, color: p.fg),
            const SizedBox(width: 10),
            // Text content (title + message)
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
                        ?.copyWith(color: p.fg.withValues(alpha: 0.95)),
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

// Minimal internal color and icon palette for notice types
class _Palette {
  const _Palette({required this.base, required this.fg, required this.icon});
  final Color base; // Accent color (background highlight)
  final Color fg;   // Foreground color (text and icon)
  final IconData icon; // Icon to display for the notice
}

// Returns the color palette and icon for each NoticeKind based on theme brightness
_Palette _palette(NoticeKind kind, bool isDark) {
  // Base colors for notice types
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

// Helper to apply opacity to base color, clamped between 0 and 1
Color _tint(Color base, double opacity) =>
    base.withValues(alpha: opacity.clamp(0.0, 1.0));
