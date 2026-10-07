import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Carga de la partida (preguntas y categorías).
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.surfaceContainerHigh,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Preparando la ruleta…',
            style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}
