import 'package:flutter/material.dart';

import '../../../../core/widgets/game_app_bar.dart';
import '../../domain/trivia_repository.dart';
import '../controllers/trivia_game_controller.dart';
import '../widgets/answer_feedback.dart';
import '../widgets/difficulty_picker.dart';
import '../widgets/loading_view.dart';
import '../widgets/question_card.dart';
import '../widgets/result_view.dart';
import '../widgets/roulette_view.dart';

class TriviaGameScreen extends StatefulWidget {
  const TriviaGameScreen({super.key, required this.repository});

  final TriviaRepository repository;

  @override
  State<TriviaGameScreen> createState() => _TriviaGameScreenState();
}

class _TriviaGameScreenState extends State<TriviaGameScreen> {
  /// Tiempo extra después de que frena la ruleta, para ver qué salió.
  static const _landingPause = Duration(milliseconds: 700);

  late TriviaGameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
  }

  TriviaGameController _createController() => TriviaGameController(
        repository: widget.repository,
        revealDelay: RouletteView.spinDuration + _landingPause,
      )..start();

  void _playAgain() {
    final old = _controller;
    setState(() => _controller = _createController());
    old.dispose();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final c = _controller;
        return Scaffold(
          extendBodyBehindAppBar: false,
          appBar: GameAppBar(title: _titleFor(c.phase)),
          body: SafeArea(
            top: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_phaseKey(c)),
                child: _buildBody(c),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Identifica cada pantalla para animar solo los cambios de paso
  /// (no cada tic del temporizador).
  String _phaseKey(TriviaGameController c) {
    final phase = switch (c.phase) {
      GamePhase.readyToSpin || GamePhase.spinning => 'roulette',
      final other => other.name,
    };
    return '${identityHashCode(c)}-$phase-${c.roundNumber}';
  }

  String _titleFor(GamePhase phase) => switch (phase) {
        GamePhase.loading => 'Trivia',
        GamePhase.choosingDifficulty => 'Dificultad',
        GamePhase.readyToSpin || GamePhase.spinning => 'Ruleta',
        GamePhase.question => 'Pregunta',
        GamePhase.answered => 'Feedback',
        GamePhase.finished => 'Resultados',
      };

  Widget _buildBody(TriviaGameController c) {
    switch (c.phase) {
      case GamePhase.loading:
        return const LoadingView();
      case GamePhase.choosingDifficulty:
        return DifficultyPicker(
          questionNumber: c.roundNumber,
          totalQuestions: c.totalQuestions,
          exhausted: c.exhaustedDifficulties,
          message: c.message,
          onConfirm: c.selectDifficulty,
        );
      case GamePhase.readyToSpin:
      case GamePhase.spinning:
        return RouletteView(
          categories: c.categories,
          difficulty: c.difficulty!,
          isSpinning: c.phase == GamePhase.spinning,
          result: c.spinResult,
          message: c.message,
          score: c.score,
          questionNumber: c.roundNumber,
          totalQuestions: c.totalQuestions,
          onSpin: c.spin,
        );
      case GamePhase.question:
        return QuestionCard(
          category: c.currentCategory!,
          question: c.currentQuestion!,
          questionNumber: c.roundNumber,
          totalQuestions: c.totalQuestions,
          remainingSeconds: c.remainingSeconds,
          totalSeconds: c.totalSeconds,
          onAnswer: c.answer,
        );
      case GamePhase.answered:
        return AnswerFeedback(
          round: c.lastRound!,
          questionNumber: c.roundNumber,
          isLastQuestion: c.isLastQuestion,
          totalQuestions: c.totalQuestions,
          onNext: c.next,
        );
      case GamePhase.finished:
        return ResultView(
          summary: c.summary,
          message: c.message,
          onPlayAgain: _playAgain,
          onExit: () => Navigator.of(context).pop(),
        );
    }
  }
}
