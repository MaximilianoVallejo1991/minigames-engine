/// Textos de marca. Junto con [AppColors] y los datos, es lo único que hay
/// que cambiar para adaptar el motor a otra temática.
abstract final class AppBrand {
  /// Nombre del hub de minijuegos (encabezado de inicio).
  static const String appName = 'Minijuegos';

  /// Nombre del juego de trivia, en dos partes (la segunda va en verde).
  static const String gameNameLead = 'Eco';
  static const String gameNameAccent = 'Trivia';
  static const String gameName = '$gameNameLead$gameNameAccent';

  static const String tagline = 'Desafío de Conciencia Planetaria';
  static const String heroTitle = 'Desafío Verde';
  static const String heroSubtitle =
      '¿Listo para demostrar tu conocimiento ecológico y proteger el planeta hoy?';
  static const String footer = 'Aprendé jugando por un futuro sostenible';
}
