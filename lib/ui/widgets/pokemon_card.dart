import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/pokemon_summary.dart';
import 'favorite_button.dart';
import 'type_chip.dart';
import 'type_icon.dart';

/// List card from the Figma design, shared by the Pokédex and Favorites
/// screens. The heart is a [FavoriteButton], so it syncs on its own.
class PokemonCard extends StatelessWidget {
  const PokemonCard({super.key, required this.pokemon, this.onTap});

  static const double _minHeight = 102;
  static const double _artworkWidth = 126;
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(15));

  final PokemonSummary pokemon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final type = pokemon.primaryType;

    return Material(
      color: type.tint,
      borderRadius: _radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _Info(pokemon: pokemon)),
                SizedBox(
                  width: _artworkWidth,
                  child: _Artwork(pokemon: pokemon),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.pokemon});

  final PokemonSummary pokemon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Formatters.pokedexNumber(pokemon.id),
            style: textTheme.labelMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              color: AppColors.grey800,
            ),
          ),
          Text(
            pokemon.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          // Scales down instead of overflowing for long type names.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                for (final (index, type) in pokemon.types.indexed) ...[
                  if (index > 0) const SizedBox(width: 4),
                  TypeChip(type: type),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.pokemon});

  static const double _imageSize = 94;

  final PokemonSummary pokemon;

  @override
  Widget build(BuildContext context) {
    final type = pokemon.primaryType;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: type.color,
        borderRadius: PokemonCard._radius,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          TypeIcon(
            type: type,
            size: _imageSize,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          CachedNetworkImage(
            imageUrl: pokemon.imageUrl,
            width: _imageSize,
            height: _imageSize,
            fit: BoxFit.contain,
            // Decode at display size instead of the full 475px artwork.
            memCacheWidth: (_imageSize * pixelRatio).round(),
            fadeInDuration: const Duration(milliseconds: 150),
            placeholder: (context, url) => const SizedBox.shrink(),
            errorWidget: (context, url, error) => const Icon(
              Icons.catching_pokemon,
              color: Colors.white,
              size: 40,
            ),
          ),
          Positioned(top: 6, right: 6, child: FavoriteButton(pokemon: pokemon)),
        ],
      ),
    );
  }
}
