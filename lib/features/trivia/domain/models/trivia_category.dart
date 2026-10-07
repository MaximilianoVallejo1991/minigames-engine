class TriviaCategory {
  const TriviaCategory({
    required this.id,
    required this.name,
    required this.colorHex,
    this.icon,
  });

  final int id;
  final String name;

  /// Color en formato '#RRGGBB'.
  final String colorHex;

  /// Nombre de ícono opcional (definido en los datos).
  final String? icon;
}
