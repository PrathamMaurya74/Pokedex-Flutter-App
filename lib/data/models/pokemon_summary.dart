import '../../core/theme/pokemon_type.dart';
import '../../core/utils/formatters.dart';

/// The small slice of a Pokémon needed to draw a card.
///
/// Favorites are stored as summaries, so the Favorites tab renders
/// instantly (and offline) without refetching anything from the API.
class PokemonSummary {
  const PokemonSummary({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  factory PokemonSummary.fromJson(Map<String, dynamic> json) => PokemonSummary(
    id: json['id'] as int,
    name: json['name'] as String,
    imageUrl: json['imageUrl'] as String,
    types: (json['types'] as List<dynamic>)
        .map((type) => PokemonType.fromApiName(type as String))
        .toList(),
  );

  final int id;
  final String name;
  final String imageUrl;
  final List<PokemonType> types;

  String get displayName => name.fromSlug;

  PokemonType get primaryType =>
      types.isEmpty ? PokemonType.normal : types.first;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'types': types.map((type) => type.name).toList(),
  };
}
