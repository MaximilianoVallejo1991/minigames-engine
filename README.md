# minigames-engine

Motor de minijuegos didácticos en Flutter. El primer juego es una **trivia con ruleta** con temática de medioambiente, pensada para servir a cualquier temática cambiando solo los datos (`assets/data/`) y los assets visuales.

## Reglas de la trivia

Cada partida tiene **10 preguntas**. Cada ronda sigue estos pasos:

1. **Elegir el nivel** de esa pregunta: Fácil (+5), Medio (+15) o Difícil (+25 puntos por acierto).
2. **Girar la ruleta** para sortear una de las 6 categorías: Reciclaje, Energía, Océanos, Flora, Clima y Consumo.
3. **Responder** eligiendo entre 3 opciones, con **30 segundos** de tiempo.
4. **Ver el resultado** con la respuesta correcta y un "¿Sabías que…?".

Una respuesta incorrecta o sin responder (tiempo agotado) suma 0 puntos y la partida sigue con el paso 1. El máximo es **250 puntos** (10 preguntas difíciles acertadas). Los resultados muestran aciertos, efectividad y desglose por nivel.

Las reglas están centralizadas en `lib/features/trivia/domain/game_rules.dart`.

## Formato de los datos

`assets/data/trivia.json` tiene dos listas planas, pensadas como tablas:

- `categories`: `id`, `name`, `color` (`#RRGGBB`), `icon`
- `questions`: `id`, `categoryId`, `difficulty` (`easy` | `medium` | `hard`), `text`, `explanation` (opcional), `image` (opcional, ruta de un asset), `options` (`id`, `text`, `isCorrect`)

Cada pregunta debe tener exactamente una opción correcta.

## Primer arranque

Este repo trae solo el código Dart y los datos. Las carpetas de plataforma (android, ios, web, windows, etc.) se generan con Flutter, que no pisa los archivos existentes:

```bash
flutter create . --project-name minigames_engine --org com.tuusuario
flutter pub get
flutter test
flutter run
```

> El `--project-name` es necesario porque el nombre de la carpeta tiene un guion y Dart no lo acepta como nombre de paquete.

## Estructura

```
assets/
  data/trivia.json        # datos actuales, con forma de tablas (sirven de seed para PostgreSQL)
  images/  sounds/
lib/
  main.dart               # ÚNICO lugar donde se elige la fuente de datos
  app.dart                # MaterialApp + tema
  core/
    theme/                # colores y tipografía de la temática
    router/               # (reservado para rutas cuando crezca la app)
    widgets/              # widgets compartidos entre juegos
  features/
    home/                 # selector de minijuegos
    trivia/
      domain/             # modelos, reglas y contrato del repositorio (Dart puro)
      data/               # implementaciones del repositorio + mapeo JSON
      presentation/       # controlador de partida, pantallas y widgets
test/                     # espejo de lib/
```

Cada minijuego nuevo es una carpeta hermana dentro de `features/`.

## Migración a PostgreSQL (más adelante)

1. Crear una API (Node/Express, Dart Frog/Serverpod o Supabase) delante de la base. **La app nunca se conecta directo a PostgreSQL**: las credenciales quedarían dentro del binario.
2. Usar `assets/data/trivia.json` como seed: `categories`, `questions` y `options` ya tienen `id` y claves foráneas (`categoryId`).
3. Agregar `lib/features/trivia/data/remote_trivia_repository.dart` implementando `TriviaRepository`.
4. Cambiar la instancia en `main.dart`. Pantallas y controlador no se tocan.
5. Opcional: mantener `LocalTriviaRepository` como respaldo offline.

## Pendientes

- Ruleta animada (`CustomPainter` + `AnimationController`) en lugar de la vista estática actual.
- Cargar más preguntas: hoy hay 18 (una por categoría y nivel). Con 10 rondas, un mismo nivel se agota a las 6 preguntas y el juego pide elegir otro.
- Pasar la UI al diseño de Figma (Minijuegos Engine V 1.0): splash, home, colores y tipografía.
- Navegación con go_router.
- Elegir gestión de estado si crece (Riverpod o provider); por ahora alcanza con `ChangeNotifier`.
