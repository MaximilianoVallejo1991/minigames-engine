import '../game_rules.dart';
import 'difficulty.dart';
import 'round_result.dart';

/// Resumen de la partida, calculado a partir de las rondas jugadas.
class GameSummary {
  const GameSummary(this.rounds);

  final List<RoundResult> rounds;

  int get score => rounds.fold(0, (sum, r) => sum + r.points);
  int get maxScore => GameRules.maxScore;
  int get roundsPlayed => rounds.length;
  int get correctCount => rounds.where((r) => r.isCorrect).length;
  int get timedOutCount =>
      rounds.where((r) => r.outcome == RoundOutcome.timedOut).length;

  /// Porcentaje de aciertos sobre las rondas jugadas (0 a 100).
  int get accuracyPercent =>
      roundsPlayed == 0 ? 0 : (correctCount * 100 / roundsPlayed).round();

  ({int correct, int total}) statsFor(Difficulty difficulty) {
    final ofDifficulty = rounds.where((r) => r.difficulty == difficulty);
    return (
      correct: ofDifficulty.where((r) => r.isCorrect).length,
      total: ofDifficulty.length,
    );
  }
}
