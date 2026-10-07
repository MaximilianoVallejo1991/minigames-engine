import 'package:flutter/material.dart';

/// Superficie "arcade" con borde inferior sólido que se hunde al presionar.
///
/// Es la base de los botones, las opciones de respuesta y las tarjetas
/// seleccionables del diseño (Tactile Arcade Stacking).
class Pressable3D extends StatefulWidget {
  const Pressable3D({
    super.key,
    required this.child,
    required this.color,
    required this.edgeColor,
    this.onTap,
    this.depth = 4,
    this.borderRadius = const BorderRadius.all(Radius.circular(9999)),
    this.border,
    this.padding = EdgeInsets.zero,
    this.semanticLabel,
    this.selected = false,
  });

  final Widget child;
  final Color color;
  final Color edgeColor;
  final VoidCallback? onTap;

  /// Altura del borde inferior en píxeles (3–5 en el diseño).
  final double depth;
  final BorderRadius borderRadius;
  final BoxBorder? border;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;
  final bool selected;

  @override
  State<Pressable3D> createState() => _Pressable3DState();
}

class _Pressable3DState extends State<Pressable3D> {
  bool _pressed = false;
  bool _hovered = false;

  bool get _enabled => widget.onTap != null;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final offset = _pressed ? widget.depth : 0.0;
    final edge = widget.depth - offset;

    return Semantics(
      button: true,
      enabled: _enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => _setPressed(true) : null,
          onTapUp: _enabled ? (_) => _setPressed(false) : null,
          onTapCancel: _enabled ? () => _setPressed(false) : null,
          onTap: widget.onTap,
          child: Padding(
            // Reserva el espacio del borde para que el layout no salte.
            padding: EdgeInsets.only(bottom: widget.depth),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(0, offset, 0),
              padding: widget.padding,
              decoration: BoxDecoration(
                color: _hovered && _enabled && !_pressed
                    ? Color.lerp(widget.color, Colors.white, 0.06)
                    : widget.color,
                borderRadius: widget.borderRadius,
                border: widget.border,
                boxShadow: [
                  if (edge > 0)
                    BoxShadow(
                      color: widget.edgeColor,
                      offset: Offset(0, edge),
                      blurRadius: 0,
                    ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
