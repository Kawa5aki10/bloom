import 'package:flutter/material.dart';

import '../app_scope.dart';

/// Big rounded "3D" button, like in Duolingo.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.shadowColor,
    this.textColor,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final Color? shadowColor;
  final Color? textColor;
  final IconData? icon;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = widget.onTap != null;
    final color = enabled ? (widget.color ?? c.primary) : c.border;
    final shadow = enabled ? (widget.shadowColor ?? c.primaryDark) : c.border;
    final textColor = enabled ? (widget.textColor ?? Colors.white) : c.muted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _down = false);
                widget.onTap?.call();
              }
            : null,
        onTapCancel: () => setState(() => _down = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          transform: Matrix4.translationValues(0, _down ? 4 : 0, 0),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: shadow, offset: Offset(0, _down ? 0 : 4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: textColor, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// White rounded card with a soft bottom edge.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding, this.color, this.borderColor});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final edge = borderColor ?? c.border;
    final card = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: edge, width: 2),
        boxShadow: [BoxShadow(color: edge, offset: const Offset(0, 4))],
      ),
      child: child,
    );
    if (onTap == null) return Padding(padding: const EdgeInsets.only(bottom: 4), child: card);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: card),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: context.colors.text),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Small rounded label with an emoji and a number (streak, XP).
class StatPill extends StatelessWidget {
  const StatPill({super.key, required this.emoji, required this.value, required this.color});

  final String emoji;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: c.border, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 5),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 16)),
        ],
      ),
    );
  }
}

/// Shows a short message at the bottom of the screen.
void showToast(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 2)));
}

const moodEmojis = ['😣', '😕', '😐', '🙂', '😄'];

String formatMinutes(int minutes, String h, String m) {
  final hh = minutes ~/ 60;
  final mm = minutes % 60;
  if (mm == 0) return '$hh $h';
  return '$hh $h $mm $m';
}
