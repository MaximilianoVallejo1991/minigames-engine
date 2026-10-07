import 'package:flutter/material.dart';

import 'app.dart';
import 'features/trivia/data/local_trivia_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Punto único donde se elige la fuente de datos.
  // Al migrar a PostgreSQL: reemplazar por RemoteTriviaRepository(...).
  final triviaRepository = LocalTriviaRepository();

  runApp(MinigamesApp(triviaRepository: triviaRepository, showSplash: true));
}
