import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/trivia/domain/trivia_repository.dart';

class MinigamesApp extends StatelessWidget {
  const MinigamesApp({super.key, required this.triviaRepository});

  final TriviaRepository triviaRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minijuegos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: HomeScreen(triviaRepository: triviaRepository),
    );
  }
}
