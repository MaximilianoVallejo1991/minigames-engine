import 'package:flutter/material.dart';

import '../trivia/domain/trivia_repository.dart';
import '../trivia/presentation/screens/trivia_game_screen.dart';

/// Selector de minijuegos. Cada juego nuevo es una carpeta hermana en features/.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.triviaRepository});

  final TriviaRepository triviaRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minijuegos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.casino_outlined, size: 32),
              title: const Text('Trivia con ruleta'),
              subtitle: const Text('Elegí el nivel, girá la ruleta y respondé 10 preguntas'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TriviaGameScreen(repository: triviaRepository),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
