import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/models/models.dart';
import '../domain/trivia_repository.dart';
import 'dtos/trivia_json_mapper.dart';

/// Lee la trivia desde un JSON empaquetado en assets.
///
/// Puede seguir usándose como respaldo offline cuando exista el repositorio
/// remoto.
class LocalTriviaRepository implements TriviaRepository {
  LocalTriviaRepository({
    AssetBundle? bundle,
    this.assetPath = 'assets/data/trivia.json',
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String assetPath;

  List<TriviaCategory>? _categories;
  List<Question>? _questions;

  Future<void> _ensureLoaded() async {
    if (_categories != null && _questions != null) return;

    final raw = await _bundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;

    _categories = (json['categories'] as List<dynamic>)
        .map((c) => TriviaJsonMapper.categoryFromJson(c as Map<String, dynamic>))
        .toList();
    _questions = (json['questions'] as List<dynamic>)
        .map((q) => TriviaJsonMapper.questionFromJson(q as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TriviaCategory>> getCategories() async {
    await _ensureLoaded();
    return List.unmodifiable(_categories!);
  }

  @override
  Future<List<Question>> getQuestions({
    required int categoryId,
    required Difficulty difficulty,
  }) async {
    await _ensureLoaded();
    return _questions!
        .where((q) => q.categoryId == categoryId && q.difficulty == difficulty)
        .toList(growable: false);
  }
}
