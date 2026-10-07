import 'models/difficulty.dart';

/// Reglas de la trivia. Centralizadas para poder ajustarlas sin tocar la UI.
///
/// - La dificultad se elige en cada pregunta.
/// - Acierto: 5 / 15 / 25 puntos según la dificultad.
/// - Incorrecta o sin responder (tiempo agotado): 0 puntos.
/// - 10 preguntas por partida, 30 segundos por pregunta.
/// - Máximo posible: 10 preguntas difíciles = 250 puntos.
abstract final class GameRules {
  static const int questionsPerGame = 10;
  static const int optionsPerQuestion = 3;
  static const int categoriesOnRoulette = 6;
  static const Duration questionTimeLimit = Duration(seconds: 30);

  static int pointsFor(Difficulty difficulty) => switch (difficulty) {
        Difficulty.easy => 5,
        Difficulty.medium => 15,
        Difficulty.hard => 25,
      };

  static int get maxScore => questionsPerGame * pointsFor(Difficulty.hard);
}
