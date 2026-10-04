import '../models/pokemon.dart';
import '../models/pokemon_page.dart';
import '../models/pokemon_species.dart';
import '../services/poke_api_service.dart';

/// The single entry point the app's state layer uses for Pokémon data.
///
/// The list endpoint only returns names and URLs, but the design's list
/// cards need types. So each page loads its 20 Pokémon details in parallel
/// and keeps them in an in-memory cache, which also makes the detail
/// screen open instantly for any Pokémon already shown in the list.
class PokemonRepository {
  PokemonRepository(this._api);

  final PokeApiService _api;

  /// Caches store futures (not values) so two simultaneous requests for
  /// the same Pokémon share one network call.
  final Map<int, Future<Pokemon>> _pokemonCache = {};
  final Map<int, Future<PokemonSpecies>> _speciesCache = {};

  Future<PokemonPage> fetchPage({String? pageUrl}) async {
    final response = await _api.fetchPokemonList(pageUrl: pageUrl);
    final items = await Future.wait(
      response.results.map((resource) => getPokemon(resource.id)),
    );
    return PokemonPage(items: items, nextPageUrl: response.next);
  }

  Future<Pokemon> getPokemon(int id) =>
      _cached(_pokemonCache, id, () => _api.fetchPokemon('$id'));

  Future<PokemonSpecies> getSpecies(int id) =>
      _cached(_speciesCache, id, () => _api.fetchSpecies(id));

  Future<T> _cached<T>(
    Map<int, Future<T>> cache,
    int id,
    Future<T> Function() load,
  ) {
    return cache.putIfAbsent(id, () async {
      try {
        return await load();
      } catch (_) {
        // Don't cache failures, so a retry makes a fresh request.
        cache.remove(id);
        rethrow;
      }
    });
  }
}
