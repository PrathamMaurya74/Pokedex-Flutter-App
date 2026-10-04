/// Extra info from `GET /pokemon-species/{id}`, used for the design's
/// description, category and gender sections.
class PokemonSpecies {
  const PokemonSpecies({this.description, this.category, this.femaleRatio});

  factory PokemonSpecies.fromJson(Map<String, dynamic> json) {
    final flavorText = _english(json['flavor_text_entries'])?['flavor_text'];
    final genus = _english(json['genera'])?['genus'] as String?;
    final genderRate = json['gender_rate'] as int;

    return PokemonSpecies(
      // Game text contains hard line breaks and form feeds; flatten them.
      description: flavorText is String
          ? flavorText.replaceAll(RegExp(r'\s+'), ' ').trim()
          : null,
      // "Seed Pokémon" → "Seed", as in the design.
      category: genus?.replaceFirst(RegExp(r'\s*Pokémon$'), ''),
      // gender_rate is the female chance in eighths, or -1 for genderless.
      femaleRatio: genderRate < 0 ? null : genderRate / 8,
    );
  }

  final String? description;
  final String? category;

  /// 0.0–1.0, or `null` when the Pokémon is genderless.
  final double? femaleRatio;

  static Map<String, dynamic>? _english(Object? entries) =>
      (entries as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .where(
            (entry) =>
                (entry['language'] as Map<String, dynamic>)['name'] == 'en',
          )
          .firstOrNull;
}
