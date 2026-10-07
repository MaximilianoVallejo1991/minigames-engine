import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Chip / badge con forma de píldora.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.icon,
    this.leading,
    this.background = AppColors.surfaceContainerLow,
    this.foreground = AppColors.onSurfaceVariant,
    this.edgeColor,
    this.border,
    this.uppercase = true,
    this.dense = false,
  });

  final String label;
  final IconData? icon;

  /// Widget opcional a la izquierda (tiene prioridad sobre [icon]).
  final Widget? leading;
  final Color background;
  final Color foreground;

  /// Borde inferior sólido opcional (look 3D).
  final Color? edgeColor;
  final Color? border;
  final bool uppercase;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final style = uppercase
        ? AppTextStyles.labelCaps.copyWith(color: foreground)
        : AppTextStyles.labelCaps.copyWith(
            color: foreground,
            fontSize: 13,
            letterSpacing: 0,
            fontWeight: FontWeight.w700,
          );

    final text = Text(
      uppercase ? label.toUpperCase() : label,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    // Con ancho acotado el texto se recorta con "…"; sin límite (p. ej. dentro
    // de un Row) toma su ancho natural. Flexible sin límite rompería el layout.
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? 10 : 12,
          vertical: dense ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(9999),
          border: border == null ? null : Border.all(color: border!, width: 1.5),
          boxShadow: edgeColor == null
              ? null
              : [BoxShadow(color: edgeColor!, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 6),
            ] else if (icon != null) ...[
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: 6),
            ],
            if (constraints.hasBoundedWidth) Flexible(child: text) else text,
          ],
        ),
      ),
    );
  }
}
