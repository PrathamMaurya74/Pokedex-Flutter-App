import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/pokemon.dart';
import 'core_providers.dart';

/// Everything the list screen needs once the first page has loaded.
class PokemonListState {
  const PokemonListState({
    required this.items,
    required this.nextPageUrl,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<Pokemon> items;

  /// The API's `next` URL; `null` once every Pokémon is loaded.
  final String? nextPageUrl;
  final bool isLoadingMore;

  /// Set when loading a *later* page fails. The loaded items stay visible
  /// and the error is shown inline at the bottom of the list.
  final Object? loadMoreError;

  bool get hasMore => nextPageUrl != null;
}

/// First-page loading and errors are expressed by [AsyncValue] (loading
/// spinner / full-screen error). Later pages update [PokemonListState].
final pokemonListProvider =
    AsyncNotifierProvider<PokemonListNotifier, PokemonListState>(
      PokemonListNotifier.new,
    );

class PokemonListNotifier extends AsyncNotifier<PokemonListState> {
  @override
  Future<PokemonListState> build() async {
    final page = await ref.watch(pokemonRepositoryProvider).fetchPage();
    return PokemonListState(items: page.items, nextPageUrl: page.nextPageUrl);
  }

  /// Loads the next page. Safe to call repeatedly while scrolling: it does
  /// nothing if a page is already loading or there is nothing left.
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasValue) return;
    final current = state.requireValue;
    if (current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(
      PokemonListState(
        items: current.items,
        nextPageUrl: current.nextPageUrl,
        isLoadingMore: true,
      ),
    );

    try {
      final page = await ref
          .read(pokemonRepositoryProvider)
          .fetchPage(pageUrl: current.nextPageUrl);
      state = AsyncData(
        PokemonListState(
          items: [...current.items, ...page.items],
          nextPageUrl: page.nextPageUrl,
        ),
      );
    } catch (error) {
      state = AsyncData(
        PokemonListState(
          items: current.items,
          nextPageUrl: current.nextPageUrl,
          loadMoreError: error,
        ),
      );
    }
  }
}
