import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_engine/features/trivia/domain/game_rules.dart';
import 'package:minigames_engine/features/trivia/domain/models/models.dart';
import 'package:minigames_engine/features/trivia/presentation/controllers/trivia_game_controller.dart';

import 'fake_trivia_repository.dart';

void main() {
  const category = TriviaCategory(id: 1, name: 'Reciclaje', colorHex: '#2E7D32');

  TriviaGameController buildController(List<Question> questions) {
    return TriviaGameController(
      repository: FakeTriviaRepository(categories: [category], questions: questions),
    );
  }

  /// Juega una ronda completa hasta la fase "answered".
  Future<void> playRound(
    TriviaGameController c,
    Difficulty difficulty, {
    required bool correct,
  }) async {
    c.selectDifficulty(difficulty);
    await c.spin();
    c.answer(c.currentQuestion!.options.firstWhere((o) => o.isCorrect == correct));
  }

  group('reglas', () {
    test('puntos por dificultad y máximo de 250', () {
      expect(GameRules.pointsFor(Difficulty.easy), 5);
      expect(GameRules.pointsFor(Difficulty.medium), 15);
      expect(GameRules.pointsFor(Difficulty.hard), 25);
      expect(GameRules.maxScore, 250);
      expect(GameRules.questionTimeLimit, const Duration(seconds: 30));
    });
  });

  group('partida', () {
    test('arranca pidiendo la dificultad', () async {
      final c = buildController(buildQuestionBank(10));
      await c.start();
      expect(c.phase, GamePhase.choosingDifficulty);
      c.dispose();
    });

    test('la pregunta respeta la dificultad elegida en la ronda', () async {
      final c = buildController(buildQuestionBank(10));
      await c.start();

      c.selectDifficulty(Difficulty.hard);
      await c.spin();
      expect(c.currentQuestion!.difficulty, Difficulty.hard);
      c.dispose();
    });

    test('suma según la dificultad y 0 si es incorrecta', () async {
      final c = buildController(buildQuestionBank(10));
      await c.start();

      await playRound(c, Difficulty.medium, correct: true);
      expect(c.score, 15);

      c.next();
      await playRound(c, Difficulty.hard, correct: false);
      expect(c.score, 15);
      expect(c.lastRound!.points, 0);
      c.dispose();
    });

    test('tiempo agotado: sin responder, 0 puntos y vuelve a elegir nivel', () async {
      final c = buildController(buildQuestionBank(10));
      await c.start();

      c.selectDifficulty(Difficulty.hard);
      await c.spin();
      c.timeOut();

      expect(c.phase, GamePhase.answered);
      expect(c.lastRound!.outcome, RoundOutcome.timedOut);
      expect(c.lastRound!.selectedOption, isNull);
      expect(c.score, 0);

      c.next();
      expect(c.phase, GamePhase.choosingDifficulty);
      c.dispose();
    });

    test('no se puede responder después de que se agotó el tiempo', () async {
      final c = buildController(buildQuestionBank(10));
      await c.start();

      c.selectDifficulty(Difficulty.easy);
      await c.spin();
      final correct = c.currentQuestion!.correctOption;
      c.timeOut();
      c.answer(correct);

      expect(c.score, 0);
      c.dispose();
    });

    test('10 preguntas difíciles correctas dan 250 y terminan la partida', () async {
      final c = buildController(buildQuestionBank(10));
      await c.start();
      final seen = <int>{};

      for (var i = 0; i < GameRules.questionsPerGame; i++) {
        await playRound(c, Difficulty.hard, correct: true);
        expect(seen.add(c.currentQuestion!.id), isTrue, reason: 'pregunta repetida');
        c.next();
      }

      expect(c.phase, GamePhase.finished);
      expect(c.score, GameRules.maxScore);
      expect(c.summary.accuracyPercent, 100);
      c.dispose();
    });

    test('el resumen desglosa aciertos por dificultad', () async {
      final c = buildController(buildQuestionBank(10));
      await c.start();

      await playRound(c, Difficulty.easy, correct: true);
      c.next();
      await playRound(c, Difficulty.easy, correct: false);
      c.next();
      await playRound(c, Difficulty.hard, correct: true);

      final easy = c.summary.statsFor(Difficulty.easy);
      final hard = c.summary.statsFor(Difficulty.hard);
      expect((easy.correct, easy.total), (1, 2));
      expect((hard.correct, hard.total), (1, 1));
      expect(c.summary.score, 5 + 25);
      c.dispose();
    });

    test('si una dificultad se queda sin preguntas, pide elegir otra', () async {
      final c = buildController([
        buildQuestion(1, difficulty: Difficulty.hard),
        buildQuestion(2, difficulty: Difficulty.easy),
      ]);
      await c.start();

      await playRound(c, Difficulty.hard, correct: true);
      c.next();
      c.selectDifficulty(Difficulty.hard);
      await c.spin();

      expect(c.phase, GamePhase.choosingDifficulty);
      expect(c.exhaustedDifficulties, contains(Difficulty.hard));
      expect(c.message, isNotNull);
      c.dispose();
    });
  });

  group('ruleta', () {
    test('con revealDelay muestra la categoría antes de arrancar la pregunta', () async {
      final c = TriviaGameController(
        repository: FakeTriviaRepository(
          categories: [category],
          questions: buildQuestionBank(2),
        ),
        revealDelay: const Duration(milliseconds: 20),
      );
      await c.start();
      c.selectDifficulty(Difficulty.easy);

      final spinning = c.spin();
      // Deja correr el sorteo, pero no la espera de la animación.
      await Future<void>.delayed(Duration.zero);

      expect(c.phase, GamePhase.spinning);
      expect(c.spinResult?.id, category.id);
      expect(c.roundNumber, 1);

      await spinning;
      expect(c.phase, GamePhase.question);
      expect(c.spinResult, isNull);
      expect(c.currentCategory?.id, category.id);
      expect(c.remainingSeconds, c.totalSeconds);
      c.dispose();
    });

    test('sin revealDelay pasa directo a la pregunta', () async {
      final c = buildController(buildQuestionBank(2));
      await c.start();
      c.selectDifficulty(Difficulty.easy);
      await c.spin();

      expect(c.phase, GamePhase.question);
      expect(c.spinResult, isNull);
      c.dispose();
    });
  });
}
