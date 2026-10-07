import 'models/models.dart';

/// Contrato de acceso a datos de la trivia.
///
/// Hoy lo implementa [LocalTriviaRepository] (JSON en assets).
/// Al migrar a PostgreSQL se agrega un RemoteTriviaRepository que hable con
/// la API (nunca directo a la base desde la app) y se cambia la
/// implementación que se inyecta en `main.dart`.
abstract interface class TriviaRepository {
  Future<List<TriviaCategory>> getCategories();

  Future<List<Question>> getQuestions({
    required int categoryId,
    required Difficulty difficulty,
  });
}
