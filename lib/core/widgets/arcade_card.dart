import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Tarjeta blanca flotante sobre el fondo, con sombra ambiental suave.
class ArcadeCard extends StatelessWidget {
  const ArcadeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppTheme.radiusLg,
    this.color = AppColors.surfaceContainerLowest,
    this.bottomEdgeColor,
    this.topEdgeColor,
    this.decorated = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;

  /// Borde inferior sólido (look 3D) opcional.
  final Color? bottomEdgeColor;

  /// Franja de color superior opcional (tarjeta de feedback).
  final Color? topEdgeColor;

  /// Agrega los círculos difuminados decorativos del diseño.
  final bool decorated;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    Widget content = Padding(padding: padding, child: child);

    if (decorated) {
      content = Stack(
        children: [
          const Positioned(
            top: -48,
            right: -48,
            child: _Blob(color: Color(0x666FFBBE), size: 150),
          ),
          const Positioned(
            bottom: -40,
            left: -40,
            child: _Blob(color: Color(0x80FFDDB8), size: 130),
          ),
          content,
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: topEdgeColor ?? bottomEdgeColor,
        borderRadius: borderRadius,
        boxShadow: AppColors.cardShadow,
      ),
      padding: EdgeInsets.only(
        top: topEdgeColor != null ? 5 : 0,
        bottom: bottomEdgeColor != null ? 4 : 0,
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        child: content,
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
