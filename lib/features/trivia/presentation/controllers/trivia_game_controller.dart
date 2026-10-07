import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../domain/game_rules.dart';
import '../../domain/models/models.dart';
import '../../domain/trivia_repository.dart';

/// Ciclo de cada ronda:
/// choosingDifficulty → readyToSpin → spinning → question → answered → (siguiente ronda o finished)
enum GamePhase {
  loading,
  choosingDifficulty,
  readyToSpin,
  spinning,
  question,
  answered,
  finished,
}

/// Estado de una partida. No sabe de dónde vienen los datos: solo usa
/// el [TriviaRepository] que recibe.
class TriviaGameController extends ChangeNotifier {
  TriviaGameController({
    required TriviaRepository repository,
    Random? random,
    this.questionTimeLimit = GameRules.questionTimeLimit,
  })  : _repository = repository,
        _random = random ?? Random();

  final TriviaRepository _repository;
  final Random _random;
  final Duration questionTimeLimit;

  final Set<int> _usedQuestionIds = {};
  final Set<Difficulty> _exhaustedDifficulties = {};
  final List<RoundResult> _rounds = [];
  List<TriviaCategory> _categories = const [];

  GamePhase _phase = GamePhase.loading;
  Difficulty? _difficulty;
  TriviaCategory? _currentCategory;
  Question? _currentQuestion;
  int _questionNumber = 0;
  int _remainingSeconds = 0;
  String? _message;
  Timer? _timer;
  bool _disposed = false;

  GamePhase get phase => _phase;
  List<TriviaCategory> get categories => _categories;
  Difficulty? get difficulty => _difficulty;
  TriviaCategory? get currentCategory => _currentCategory;
  Question? get currentQuestion => _currentQuestion;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => questionTimeLimit.inSeconds;
  int get totalQuestions => GameRules.questionsPerGame;
  String? get message => _message;
  Set<Difficulty> get exhaustedDifficulties =>
      Set.unmodifiable(_exhaustedDifficulties);

  /// Resultado de la última ronda (útil en la fase [GamePhase.answered]).
  RoundResult? get lastRound => _rounds.isEmpty ? null : _rounds.last;

  GameSummary get summary => GameSummary(List.unmodifiable(_rounds));
  int get score => summary.score;

  /// Número de la pregunta que se está jugando (o por jugar) para mostrar en pantalla.
  int get roundNumber {
    final inProgress = _phase == GamePhase.question ||
        _phase == GamePhase.answered ||
        _phase == GamePhase.finished;
    final number = inProgress ? _questionNumber : _questionNumber + 1;
    if (number < 1) return 1;
    if (number > GameRules.questionsPerGame) return GameRules.questionsPerGame;
    return number;
  }

  bool get isLastQuestion => _questionNumber >= GameRules.questionsPerGame;

  Future<void> start() async {
    _phase = GamePhase.loading;
    _notify();
    try {
      _categories = await _repository.getCategories();
      if (_categories.isEmpty) {
        _message = 'No hay categorías cargadas.';
        _phase = GamePhase.finished;
      } else {
        _phase = GamePhase.choosingDifficulty;
      }
    } catch (e) {
      _message = 'No se pudieron cargar los datos: $e';
      _phase = GamePhase.finished;
    }
    _notify();
  }

  void selectDifficulty(Difficulty difficulty) {
    if (_phase != GamePhase.choosingDifficulty) return;
    if (_exhaustedDifficulties.contains(difficulty)) return;
    _difficulty = difficulty;
    _message = null;
    _phase = GamePhase.readyToSpin;
    _notify();
  }

  /// Gira la ruleta: elige al azar una categoría que todavía tenga
  /// preguntas sin usar para la dificultad elegida.
  Future<void> spin() async {
    final difficulty = _difficulty;
    if (_phase != GamePhase.readyToSpin || difficulty == null) return;
    _phase = GamePhase.spinning;
    _message = null;
    _notify();

    try {
      final shuffled = [..._categories]..shuffle(_random);
      for (final category in shuffled) {
        final questions = await _repository.getQuestions(
          categoryId: category.id,
          difficulty: difficulty,
        );
        final available =
            questions.where((q) => !_usedQuestionIds.contains(q.id)).toList();
        if (available.isEmpty) continue;

        final question = available[_random.nextInt(available.length)];
        _usedQuestionIds.add(question.id);
        _currentCategory = category;
        _currentQuestion = question;
        _questionNumber++;
        _phase = GamePhase.question;
        _startTimer();
        _notify();
        return;
      }

      // No quedan preguntas de esta dificultad.
      _exhaustedDifficulties.add(difficulty);
      _difficulty = null;
      if (_exhaustedDifficulties.length == Difficulty.values.length) {
        _message = 'Se terminaron las preguntas disponibles.';
        _phase = GamePhase.finished;
      } else {
        _message =
            'No quedan preguntas de nivel ${difficulty.label}. Elegí otro nivel.';
        _phase = GamePhase.choosingDifficulty;
      }
    } catch (e) {
      _message = 'Error al obtener preguntas: $e';
      _phase = GamePhase.readyToSpin;
    }
    _notify();
  }

  void answer(AnswerOption option) {
    if (_phase != GamePhase.question) return;
    _stopTimer();
    _recordRound(
      option.isCorrect ? RoundOutcome.correct : RoundOutcome.incorrect,
      selectedOption: option,
    );
  }

  /// Se llama sola cuando el temporizador llega a cero.
  /// Público para poder probarlo sin esperar 30 segundos.
  void timeOut() {
    if (_phase != GamePhase.question) return;
    _stopTimer();
    _remainingSeconds = 0;
    _recordRound(RoundOutcome.timedOut);
  }

  /// Pasa a la siguiente ronda (elegir dificultad) o a los resultados.
  void next() {
    if (_phase != GamePhase.answered) return;
    _difficulty = null;
    _phase = isLastQuestion ? GamePhase.finished : GamePhase.choosingDifficulty;
    _notify();
  }

  void _recordRound(RoundOutcome outcome, {AnswerOption? selectedOption}) {
    _rounds.add(RoundResult(
      question: _currentQuestion!,
      category: _currentCategory!,
      outcome: outcome,
      selectedOption: selectedOption,
    ));
    _phase = GamePhase.answered;
    _notify();
  }

  void _startTimer() {
    _stopTimer();
    _remainingSeconds = questionTimeLimit.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _remainingSeconds--;
      if (_remainingSeconds <= 0) {
        timeOut();
      } else {
        _notify();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _stopTimer();
    super.dispose();
  }
}
