import '../../domain/models/models.dart';

/// Convierte el JSON (con forma de tablas: categories / questions / options)
/// a modelos de dominio. El mismo formato sirve como seed de la base de datos.
abstract final class TriviaJsonMapper {
  static TriviaCategory categoryFromJson(Map<String, dynamic> json) {
    return TriviaCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      colorHex: json['color'] as String,
      icon: json['icon'] as String?,
    );
  }

  static AnswerOption optionFromJson(Map<String, dynamic> json) {
    return AnswerOption(
      id: json['id'] as int,
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool,
    );
  }

  static Question questionFromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int,
      difficulty: Difficulty.values.byName(json['difficulty'] as String),
      text: json['text'] as String,
      explanation: json['explanation'] as String?,
      image: json['image'] as String?,
      options: (json['options'] as List<dynamic>)
          .map((o) => optionFromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}
