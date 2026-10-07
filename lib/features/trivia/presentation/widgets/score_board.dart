import 'package:flutter/material.dart';

class ScoreBoard extends StatelessWidget {
  const ScoreBoard({
    super.key,
    required this.score,
    required this.maxScore,
    required this.questionNumber,
    required this.totalQuestions,
  });

  final int score;
  final int maxScore;
  final int questionNumber;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Pregunta $questionNumber de $totalQuestions', style: textTheme.titleMedium),
        Text('Puntaje: $score', style: textTheme.titleMedium),
      ],
    );
  }
}
