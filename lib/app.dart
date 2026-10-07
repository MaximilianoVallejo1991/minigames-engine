import 'package:flutter/material.dart';

import 'core/theme/app_brand.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/trivia/domain/trivia_repository.dart';

class MinigamesApp extends StatelessWidget {
  const MinigamesApp({
    super.key,
    required this.triviaRepository,
    this.showSplash = false,
  });

  final TriviaRepository triviaRepository;

  /// Muestra la pantalla de carga inicial antes del inicio.
  /// Apagada por defecto para que los tests arranquen directo en el inicio.
  final bool showSplash;

  @override
  Widget build(BuildContext context) {
    Widget home(BuildContext _) => HomeScreen(triviaRepository: triviaRepository);

    return MaterialApp(
      title: AppBrand.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: showSplash ? SplashScreen(next: home) : home(context),
    );
  }
}
