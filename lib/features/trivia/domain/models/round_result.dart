import '../game_rules.dart';
import 'answer_option.dart';
import 'difficulty.dart';
import 'question.dart';
import 'trivia_category.dart';

enum RoundOutcome { correct, incorrect, timedOut }

/// Resultado de una ronda (una pregunta).
class RoundResult {
  const RoundResult({
    required this.question,
    required this.category,
    required this.outcome,
    this.selectedOption,
  });

  final Question question;
  final TriviaCategory category;
  final RoundOutcome outcome;

  /// Null cuando se acabó el tiempo sin responder.
  final AnswerOption? selectedOption;

  Difficulty get difficulty => question.difficulty;
  bool get isCorrect => outcome == RoundOutcome.correct;

  /// Incorrecta o sin responder: 0 puntos.
  int get points => isCorrect ? GameRules.pointsFor(difficulty) : 0;
}
