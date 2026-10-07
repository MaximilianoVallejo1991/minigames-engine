import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Logo circular de la app (hoja sobre verde, con borde 3D).
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40, this.icon = Icons.eco});

  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryFixedDim, AppColors.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryStrong,
            offset: Offset(0, size * 0.075),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.55),
    );
  }
}
