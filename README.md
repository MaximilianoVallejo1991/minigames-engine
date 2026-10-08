# minigames-engine

Motor de minijuegos didácticos en Flutter. El primer juego es una **trivia con ruleta** con temática de medioambiente, pensada para servir a cualquier temática cambiando solo los datos (`assets/data/`) y los assets visuales.

## Decisiones técnicas

- **Flutter multiplataforma** (Android, iOS, web, Windows, Linux, macOS). El MVP se valida principalmente en web (GitHub Pages) y Windows.
- **Arquitectura por capas dentro de cada feature**: `domain/` (modelos, reglas, contrato de repositorio en Dart puro, sin Flutter) → `data/` (implementación concreta del repositorio) → `presentation/` (controlador + pantallas + widgets). El objetivo es poder cambiar la fuente de datos sin tocar UI ni reglas de juego.
- **Patrón Repository para los datos**, pensado de entrada para migrar a un backend propio:
  - `TriviaRepository` es la interfaz (`lib/features/trivia/domain/trivia_repository.dart`).
  - `LocalTriviaRepository` es la única implementación hoy: lee `assets/data/trivia.json` empaquetado en el binario.
  - `lib/main.dart` es el único lugar donde se elige la implementación. El día que exista una API, se agrega `RemoteTriviaRepository` y se cambia una línea ahí.
  - **La app nunca se conecta directo a una base de datos** (ni ahora ni en el plan a futuro): siempre va a haber una API en el medio para no exponer credenciales dentro del binario cliente.
- **Gestión de estado**: `ChangeNotifier` simple (`TriviaGameController`), sin librería externa. Es una decisión deliberada para el tamaño actual del proyecto, no un olvido — ver "Pendientes" para cuándo reconsiderarlo.
- **Navegación**: `Navigator` imperativo (`MaterialPageRoute`, `pushReplacement`). `go_router` está declarado en `pubspec.yaml` y la carpeta `lib/core/router/` está reservada, pero **todavía no se usa en ningún lado** — es deuda pendiente, no una capa activa.
- **Tipografías embebidas** (Plus Jakarta Sans + Inter, licencia OFL) en `assets/fonts/`, no se descargan en runtime. Elegido para que el look Arcade Neo-Pop no dependa de Google Fonts ni de conexión.
- **Datos con forma de tablas** (`categories`, `questions` con `categoryId` como foránea) aunque hoy viajen en un JSON de assets — así el mismo archivo sirve de seed el día que haya una base real detrás de la API.

## Qué se sube al repo

Está versionado el proyecto Flutter completo, incluidas las carpetas de plataforma (`android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`) generadas por `flutter create`. No quedan afuera ni se regeneran a mano.

Lo que **no** se sube (`.gitignore`):

- Artefactos de build y cachés de herramientas: `build/`, `.dart_tool/`, `.pub-cache/`, `coverage/`.
- Configuración local de IDE: `.idea/`, `.vscode/`, `*.iml`.
- Config local de herramientas de IA (`.atl/`), específica de cada máquina.
- Secretos y material de firma: `.env`, `.env.*`, `*.jks`, `*.keystore`, `*.p12`, `android/key.properties`.

## Primer arranque

```bash
flutter pub get
flutter test
flutter run
```

No hace falta `flutter create`: las carpetas de plataforma ya están en el repo.

## Pantalla de carga: qué resuelve cada pieza

Hay dos capas distintas, que no hay que confundir:

1. **Loader HTML/CSS puro, pre-engine** (`web/index.html`, `#app-loader` + `web/flutter_bootstrap.js`). Se pinta apenas el navegador parsea el `body` — sin esperar a ningún JS ni al engine de Flutter — y cubre el hueco en blanco real: el tiempo de descarga del engine/CanvasKit y los assets iniciales. `flutter_bootstrap.js` sobreescribe el que genera `flutter build web` para escuchar el evento `flutter-first-frame` (lo dispara el engine cuando pinta su primer frame) y recién ahí hacer fade-out y sacar el loader del DOM. Está implementado y cubre exactamente ese gap.
2. **`SplashScreen` de Flutter** (`lib/features/splash/splash_screen.dart`), mostrado desde `app.dart` antes del `HomeScreen`. Es el primer frame que pinta Flutter, así que el loader HTML se retira justo cuando este splash ya está en pantalla — sin que se note un salto ni se superpongan los dos. Pero sigue siendo **una animación con duración fija** (2200 ms), no un gate sobre carga real: no espera a `LocalTriviaRepository.getCategories()` (esa carga la dispara `HomeScreen` por su cuenta con un `FutureBuilder`, y si no resolvió todavía simplemente no muestra la tarjeta de categorías). Queda igual que antes — es una mejora aparte, no parte de este fix.

En criollo: el hueco en blanco real (antes de que exista cualquier widget de Flutter) ya está tapado. Lo que sigue pendiente es que el splash de Flutter deje de ser un timer fijo y pase a esperar carga real — ver "Pendientes".

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

## Diseño visual: Arcade Neo-Pop

La estética sale del diseño hecho en Google Stitch (botones 3D tipo arcade, tarjetas blancas tipo píldora, verde esmeralda + ámbar).

- `lib/core/theme/app_colors.dart`: paleta (los colores de cada categoría están en `assets/data/trivia.json`).
- `lib/core/theme/app_text_styles.dart`: tipografía — **Plus Jakarta Sans** (títulos, botones, contadores) e **Inter** (textos). Están embebidas en `assets/fonts/` (licencia OFL), no se descargan en runtime.
- `lib/core/theme/app_brand.dart`: nombres y textos de marca.
- `lib/core/widgets/`: componentes base (`ArcadeButton`, `Pressable3D`, `ArcadeCard`, `Pill`, `PillProgressBar`, `GameAppBar`, `GameBody`).
- El ícono de cada categoría se elige en los datos con el nombre de Material Icons (`recycling`, `bolt`, `water_drop`, …); los disponibles están en `lib/features/trivia/presentation/category_style.dart`.

Para otra temática: cambiar `AppColors`, `AppBrand` y los datos.

## Demo web

Cada push a `main` publica la versión web en **https://maximilianovallejo1991.github.io/minigames-engine/** (ver `.github/workflows/deploy-pages.yml`). Requiere, una sola vez: *Settings → Pages → Source: GitHub Actions*.

## Estructura

```
assets/
  data/trivia.json        # datos actuales, con forma de tablas (sirven de seed para un backend futuro)
  images/  sounds/  fonts/
lib/
  main.dart               # ÚNICO lugar donde se elige la fuente de datos (repositorio)
  app.dart                # MaterialApp + tema + arranque del splash
  core/
    theme/                # colores, tipografía y marca (Arcade Neo-Pop)
    router/               # reservado para go_router; sin uso todavía
    widgets/              # widgets compartidos entre juegos
  features/
    splash/               # intro animada de duración fija (ver limitaciones arriba)
    home/                 # inicio / selector de minijuegos
    trivia/
      domain/             # modelos, reglas y contrato del repositorio (Dart puro)
      data/                # implementaciones del repositorio + mapeo JSON
      presentation/       # controlador de partida, pantallas y widgets
test/                     # espejo de lib/
android/ ios/ web/ windows/ linux/ macos/   # carpetas de plataforma, generadas por Flutter y versionadas
```

Cada minijuego nuevo es una carpeta hermana dentro de `features/`.

## Migración a un backend propio (más adelante)

1. Crear una API (Node/Express, Dart Frog/Serverpod o Supabase) delante de la base. **La app nunca se conecta directo a la base**: las credenciales quedarían dentro del binario.
2. Usar `assets/data/trivia.json` como seed: `categories`, `questions` y `options` ya tienen `id` y claves foráneas (`categoryId`).
3. Agregar `lib/features/trivia/data/remote_trivia_repository.dart` implementando `TriviaRepository`.
4. Cambiar la instancia en `main.dart`. Pantallas y controlador no se tocan.
5. Opcional: mantener `LocalTriviaRepository` como respaldo offline.

## Pendientes

- Atar el `SplashScreen` de Flutter a carga real (hoy es un timer fijo de 2200 ms) en vez de a `AnimationController.forward()` — ver sección "Pantalla de carga" arriba.
- Cargar más preguntas: hoy hay 18 (una por categoría y nivel). Con 10 rondas, un mismo nivel se agota a las 6 preguntas y el juego pide elegir otro.
- Sonido (toggle del inicio) y compartir puntaje, que aparecen en el diseño de Stitch.
- Activar la navegación con `go_router` (hoy declarada pero sin uso) o retirarla si no se va a usar.
- Elegir gestión de estado si el proyecto crece (Riverpod o provider); por ahora alcanza con `ChangeNotifier`.
