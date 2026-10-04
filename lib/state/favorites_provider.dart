import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/pokemon_summary.dart';
import 'core_providers.dart';

/// The single source of truth for favorites across the whole app.
///
/// Every screen watches this one provider. A toggle anywhere replaces the
/// state once, and every widget watching it rebuilds automatically, so the
/// list, detail and Favorites screens can never disagree.
final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Map<int, PokemonSummary>>(
      FavoritesNotifier.new,
    );

class FavoritesNotifier extends Notifier<Map<int, PokemonSummary>> {
  @override
  Map<int, PokemonSummary> build() {
    final saved = ref.watch(favoritesStorageProvider).load();
    return {for (final pokemon in saved) pokemon.id: pokemon};
  }

  bool isFavorite(int id) => state.containsKey(id);

  Future<void> toggle(PokemonSummary pokemon) =>
      isFavorite(pokemon.id) ? remove(pokemon.id) : add(pokemon);

  Future<void> add(PokemonSummary pokemon) =>
      _update({...state, pokemon.id: pokemon});

  Future<void> remove(int id) => _update({...state}..remove(id));

  /// Updates the UI immediately, then persists. If saving fails, the
  /// change is rolled back so the UI never shows unsaved state.
  Future<void> _update(Map<int, PokemonSummary> next) async {
    final previous = state;
    state = next;
    try {
      await ref.read(favoritesStorageProvider).save(next.values);
    } catch (_) {
      state = previous;
      rethrow;
    }
  }
}
