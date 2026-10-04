extension StringCasing on String {
  /// `"bulbasaur"` → `"Bulbasaur"`.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// `"special-attack"` → `"Special Attack"`.
  String get fromSlug => split('-').map((word) => word.capitalized).join(' ');
}

abstract final class Formatters {
  /// `1` → `"Nº001"`.
  static String pokedexNumber(int id) => 'Nº${id.toString().padLeft(3, '0')}';

  /// PokéAPI height is in decimeters: `7` → `"0.7 m"`.
  static String height(int decimeters) =>
      '${(decimeters / 10).toStringAsFixed(1)} m';

  /// PokéAPI weight is in hectograms: `69` → `"6.9 kg"`.
  static String weight(int hectograms) =>
      '${(hectograms / 10).toStringAsFixed(1)} kg';
}
