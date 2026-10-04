import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/pokemon_summary.dart';
import '../../state/favorites_provider.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/state_views.dart';
import 'pokemon_detail_screen.dart';

/// Lists only favorited Pokémon. It watches the same [favoritesProvider]
/// as every heart in the app, so it updates live: unfavorite anywhere and
/// the card disappears here; favorite anywhere and it appears.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sorted by Pokédex number, as in the design.
    final favorites = ref.watch(favoritesProvider).values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            Expanded(
              child: favorites.isEmpty
                  ? EmptyView(
                      image: Image.asset(
                        'assets/images/empty_favorites.png',
                        height: 200,
                        // Never crash the empty state over a missing image.
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.favorite_border,
                              size: 96,
                              color: AppColors.grey200,
                            ),
                      ),
                      title: "You haven't favorited any Pokémon :(",
                      message:
                          'Tap the heart on any Pokémon and it will '
                          'show up here.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: favorites.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _SwipeToRemove(pokemon: favorites[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey50)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Text(
          'Favorites',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.grey800,
          ),
        ),
      ),
    );
  }
}

/// Swipe left to remove, with a red trash background as in the design,
/// plus an Undo action in case the swipe was accidental.
class _SwipeToRemove extends ConsumerWidget {
  const _SwipeToRemove({required this.pokemon});

  final PokemonSummary pokemon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(favoritesProvider.notifier);

    return Dismissible(
      key: ValueKey('favorite-${pokemon.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 32),
        decoration: const BoxDecoration(
          color: AppColors.favorite,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 34),
      ),
      onDismissed: (direction) => _remove(context, notifier),
      child: PokemonCard(
        pokemon: pokemon,
        onTap: () =>
            Navigator.of(context).push(PokemonDetailScreen.route(pokemon)),
      ),
    );
  }

  Future<void> _remove(BuildContext context, FavoritesNotifier notifier) async {
    // The card leaves the tree as soon as it's dismissed, so grab the
    // messenger now instead of using `context` after the await.
    final messenger = ScaffoldMessenger.of(context);
    try {
      await notifier.remove(pokemon.id);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't remove favorite. Try again.")),
      );
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${pokemon.displayName} removed from favorites'),
          action: SnackBarAction(
            label: 'Undo',
            // A failed save rolls itself back in the notifier.
            onPressed: () => notifier.add(pokemon).ignore(),
          ),
        ),
      );
  }
}
