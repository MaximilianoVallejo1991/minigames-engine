import 'package:minigames_engine/features/trivia/domain/models/models.dart';
import 'package:minigames_engine/features/trivia/domain/trivia_repository.dart';

/// Repositorio en memoria para tests: no toca assets ni red.
class FakeTriviaRepository implements TriviaRepository {
  FakeTriviaRepository({required this.categories, required this.questions});

  final List<TriviaCategory> categories;
  final List<Question> questions;

  @override
  Future<List<TriviaCategory>> getCategories() async => categories;

  @override
  Future<List<Question>> getQuestions({
    required int categoryId,
    required Difficulty difficulty,
  }) async =>
      questions
          .where((q) => q.categoryId == categoryId && q.difficulty == difficulty)
          .toList();
}

Question buildQuestion(
  int id, {
  int categoryId = 1,
  Difficulty difficulty = Difficulty.easy,
}) =>
    Question(
      id: id,
      categoryId: categoryId,
      difficulty: difficulty,
      text: 'Pregunta $id',
      explanation: 'Explicación $id',
      options: [
        AnswerOption(id: id * 10 + 1, text: 'Correcta', isCorrect: true),
        AnswerOption(id: id * 10 + 2, text: 'Incorrecta A', isCorrect: false),
        AnswerOption(id: id * 10 + 3, text: 'Incorrecta B', isCorrect: false),
      ],
    );

/// [perDifficulty] preguntas de cada dificultad, con ids únicos.
List<Question> buildQuestionBank(int perDifficulty) => [
      for (final d in Difficulty.values)
        for (var i = 0; i < perDifficulty; i++)
          buildQuestion(d.index * 1000 + i + 1, difficulty: d),
    ];
