class PokemonStat {
  const PokemonStat({required this.name, required this.value});

  factory PokemonStat.fromJson(Map<String, dynamic> json) => PokemonStat(
    name: (json['stat'] as Map<String, dynamic>)['name'] as String,
    value: json['base_stat'] as int,
  );

  /// PokéAPI stat name, e.g. `special-attack`.
  final String name;
  final int value;

  /// Highest possible base stat, used to scale stat bars.
  static const int maxValue = 255;

  String get label => switch (name) {
    'hp' => 'HP',
    'attack' => 'Attack',
    'defense' => 'Defense',
    'special-attack' => 'Sp. Atk',
    'special-defense' => 'Sp. Def',
    'speed' => 'Speed',
    _ => name,
  };
}
