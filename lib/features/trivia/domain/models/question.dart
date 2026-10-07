import 'answer_option.dart';
import 'difficulty.dart';

class Question {
  const Question({
    required this.id,
    required this.categoryId,
    required this.difficulty,
    required this.text,
    required this.options,
    this.explanation,
    this.image,
  });

  final int id;
  final int categoryId;
  final Difficulty difficulty;
  final String text;
  final List<AnswerOption> options;

  /// Texto del "¿Sabías que…?" que se muestra después de responder.
  final String? explanation;

  /// Ruta de la imagen de la pregunta (asset o URL). Opcional.
  final String? image;

  AnswerOption get correctOption => options.firstWhere((o) => o.isCorrect);
}
