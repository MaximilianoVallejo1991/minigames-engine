import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_engine/app.dart';

import 'features/trivia/fake_trivia_repository.dart';

void main() {
  testWidgets('la home muestra el juego de trivia', (tester) async {
    await tester.pumpWidget(
      MinigamesApp(
        triviaRepository: FakeTriviaRepository(categories: [], questions: []),
      ),
    );

    expect(find.text('Minijuegos'), findsOneWidget);
    expect(find.text('Trivia con ruleta'), findsOneWidget);
  });
}
