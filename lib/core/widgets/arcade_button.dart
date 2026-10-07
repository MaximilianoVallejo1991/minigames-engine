import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'pressable_3d.dart';

enum ArcadeButtonVariant {
  /// Verde esmeralda: acción principal.
  primary,

  /// Verde oscuro: acción principal en pantallas de cierre.
  dark,

  /// Lila claro: acción secundaria.
  secondary,
}

/// Botón 3D tipo arcade (mínimo 56 px de alto, forma de píldora).
class ArcadeButton extends StatelessWidget {
  const ArcadeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.variant = ArcadeButtonVariant.primary,
    this.height = 56,
    this.uppercase = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final ArcadeButtonVariant variant;
  final double height;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final (Color fill, Color edge, Color foreground) = switch (variant) {
      ArcadeButtonVariant.primary => (
          AppColors.primary,
          AppColors.primaryEdge,
          Colors.white,
        ),
      ArcadeButtonVariant.dark => (
          AppColors.primaryDark,
          AppColors.onPrimaryFixed,
          Colors.white,
        ),
      ArcadeButtonVariant.secondary => (
          AppColors.surfaceContainer,
          AppColors.surfaceDim,
          AppColors.onSurface,
        ),
    };

    final text = uppercase ? label.toUpperCase() : label;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SizedBox(
        width: double.infinity,
        child: Pressable3D(
          onTap: onPressed,
          color: fill,
          // Profundidad fija para que el botón no "salte" al habilitarse.
          edgeColor: enabled ? edge : Colors.transparent,
          depth: 5,
          semanticLabel: label,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: foreground, size: 24),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.button.copyWith(
                        color: foreground,
                        fontSize: height >= 64 ? 18 : 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 10),
                    Icon(trailingIcon, color: foreground, size: 22),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
