import 'package:flutter/material.dart';

import '../../domain/trivia_repository.dart';
import '../controllers/trivia_game_controller.dart';
import '../widgets/answer_feedback.dart';
import '../widgets/difficulty_picker.dart';
import '../widgets/question_card.dart';
import '../widgets/result_view.dart';
import '../widgets/roulette_view.dart';
import '../widgets/score_board.dart';

class TriviaGameScreen extends StatefulWidget {
  const TriviaGameScreen({super.key, required this.repository});

  final TriviaRepository repository;

  @override
  State<TriviaGameScreen> createState() => _TriviaGameScreenState();
}

class _TriviaGameScreenState extends State<TriviaGameScreen> {
  late final TriviaGameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TriviaGameController(repository: widget.repository)..start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trivia')),
      body: SafeArea(
        child: Center(
          // Diseño pensado para celular: en pantallas anchas se centra.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                final c = _controller;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ScoreBoard(
                        score: c.score,
                        maxScore: c.summary.maxScore,
                        questionNumber: c.roundNumber,
                        totalQuestions: c.totalQuestions,
                      ),
                      const SizedBox(height: 16),
                      Expanded(child: _buildBody(c)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(TriviaGameController c) {
    switch (c.phase) {
      case GamePhase.loading:
        return const Center(child: CircularProgressIndicator());
      case GamePhase.choosingDifficulty:
        return DifficultyPicker(
          // Key por ronda para que se reinicie la selección en cada pregunta.
          key: ValueKey('difficulty-${c.roundNumber}'),
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
          message: c.message,
          onSpin: c.spin,
        );
      case GamePhase.question:
        return QuestionCard(
          category: c.currentCategory!,
          question: c.currentQuestion!,
          remainingSeconds: c.remainingSeconds,
          totalSeconds: c.totalSeconds,
          onAnswer: c.answer,
        );
      case GamePhase.answered:
        return AnswerFeedback(
          round: c.lastRound!,
          isLastQuestion: c.isLastQuestion,
          nextQuestionNumber: c.roundNumber + 1,
          totalQuestions: c.totalQuestions,
          onNext: c.next,
        );
      case GamePhase.finished:
        return ResultView(
          summary: c.summary,
          message: c.message,
          onExit: () => Navigator.of(context).pop(),
        );
    }
  }
}
