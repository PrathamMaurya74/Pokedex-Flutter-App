import '../../core/constants/api_constants.dart';
import '../../core/theme/pokemon_type.dart';
import '../../core/utils/formatters.dart';
import 'pokemon_stat.dart';
import 'pokemon_summary.dart';

/// A Pokémon parsed from `GET /pokemon/{id}`.
///
/// Used by both the list cards (id, name, types, image) and the detail
/// screen (height, weight, abilities, stats).
class Pokemon {
  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.stats,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final sprites = json['sprites'] as Map<String, dynamic>;
    final other = sprites['other'] as Map<String, dynamic>?;
    final artwork = other?['official-artwork'] as Map<String, dynamic>?;

    return Pokemon(
      id: id,
      name: json['name'] as String,
      // Some alternate forms have no official artwork, so fall back.
      imageUrl:
          artwork?['front_default'] as String? ??
          sprites['front_default'] as String? ??
          ApiConstants.artworkUrl(id),
      types: (json['types'] as List<dynamic>)
          .map(
            (e) => (e as Map<String, dynamic>)['type'] as Map<String, dynamic>,
          )
          .map((type) => PokemonType.fromApiName(type['name'] as String))
          .toList(),
      height: json['height'] as int,
      weight: json['weight'] as int,
      abilities: (json['abilities'] as List<dynamic>)
          .map(
            (e) =>
                (e as Map<String, dynamic>)['ability'] as Map<String, dynamic>,
          )
          .map((ability) => (ability['name'] as String).fromSlug)
          .toList(),
      stats: (json['stats'] as List<dynamic>)
          .map((e) => PokemonStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;

  /// Raw API name, e.g. `mr-mime`. Use [displayName] in the UI.
  final String name;
  final String imageUrl;
  final List<PokemonType> types;

  /// In decimeters (API unit). Format with `Formatters.height`.
  final int height;

  /// In hectograms (API unit). Format with `Formatters.weight`.
  final int weight;
  final List<String> abilities;
  final List<PokemonStat> stats;

  String get displayName => name.fromSlug;

  /// First type drives the card and header colors.
  PokemonType get primaryType => types.first;

  /// The parts needed for cards and for saving as a favorite.
  PokemonSummary get summary =>
      PokemonSummary(id: id, name: name, imageUrl: imageUrl, types: types);
}
