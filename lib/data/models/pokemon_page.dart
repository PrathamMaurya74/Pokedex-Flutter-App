import 'pokemon.dart';

/// One page of fully loaded Pokémon, ready for the list screen.
class PokemonPage {
  const PokemonPage({required this.items, this.nextPageUrl});

  final List<Pokemon> items;

  /// The API's `next` URL. `null` means there is nothing more to load.
  final String? nextPageUrl;

  bool get hasMore => nextPageUrl != null;
}
