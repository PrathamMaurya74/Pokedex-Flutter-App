import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/favorites_storage.dart';
import '../data/repositories/pokemon_repository.dart';
import '../data/services/poke_api_service.dart';

/// Created asynchronously in `main()` and injected with `overrideWithValue`,
/// so every other provider can read preferences synchronously.
final sharedPreferencesProvider = Provider<SharedPreferencesWithCache>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

final favoritesStorageProvider = Provider<FavoritesStorage>(
  (ref) => FavoritesStorage(ref.watch(sharedPreferencesProvider)),
);

final pokeApiServiceProvider = Provider<PokeApiService>((ref) {
  final service = PokeApiService();
  ref.onDispose(service.dispose);
  return service;
});

final pokemonRepositoryProvider = Provider<PokemonRepository>(
  (ref) => PokemonRepository(ref.watch(pokeApiServiceProvider)),
);
