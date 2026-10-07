import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Contenedor de las pantallas: centrado, con ancho máximo y márgenes del diseño.
///
/// [scrollable] apila [children] en una lista con scroll y deja [footer]
/// (normalmente el botón principal) fijo abajo.
class GameBody extends StatelessWidget {
  const GameBody({
    super.key,
    required this.children,
    this.footer,
    this.spacing = 16,
  });

  final List<Widget> children;
  final Widget? footer;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) items.add(SizedBox(height: spacing));
      items.add(children[i]);
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.margin,
                  12,
                  AppTheme.margin,
                  16,
                ),
                children: items,
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.margin,
                  4,
                  AppTheme.margin,
                  12,
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}
