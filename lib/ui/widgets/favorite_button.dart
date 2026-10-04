import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/pokemon_summary.dart';
import '../../state/favorites_provider.dart';

enum FavoriteButtonVariant {
  /// 32px translucent circle, used on list and Favorites cards.
  card,

  /// Plain large heart, used in the detail screen header.
  header,
}

/// Heart toggle that reads and writes the shared [favoritesProvider].
///
/// Because it manages its own state through the provider, it stays in sync
/// wherever it is placed, with no callbacks needed from parent screens.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({
    super.key,
    required this.pokemon,
    this.variant = FavoriteButtonVariant.card,
  });

  final PokemonSummary pokemon;
  final FavoriteButtonVariant variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `select` rebuilds this button only when *this* Pokémon's status
    // changes, not when any other favorite is toggled.
    final isFavorite = ref.watch(
      favoritesProvider.select(
        (favorites) => favorites.containsKey(pokemon.id),
      ),
    );
    final isCard = variant == FavoriteButtonVariant.card;

    final heart = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        key: ValueKey(isFavorite),
        color: isFavorite ? AppColors.heart : Colors.white,
        size: isCard ? 18 : 28,
      ),
    );

    return Tooltip(
      message: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      child: InkResponse(
        onTap: () => _toggle(context, ref),
        radius: 24,
        child: isCard
            ? Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: heart,
              )
            : Padding(padding: const EdgeInsets.all(8), child: heart),
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(favoritesProvider.notifier).toggle(pokemon);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't save favorite. Try again.")),
      );
    }
  }
}
