import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/pokemon_type.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/pokemon.dart';
import '../../data/models/pokemon_species.dart';
import '../../data/models/pokemon_stat.dart';
import '../../data/models/pokemon_summary.dart';
import '../../state/pokemon_detail_provider.dart';
import '../widgets/favorite_button.dart';
import '../widgets/state_views.dart';
import '../widgets/type_chip.dart';
import '../widgets/type_icon.dart';

class PokemonDetailScreen extends ConsumerWidget {
  const PokemonDetailScreen({super.key, required this.pokemon});

  /// Header, name and types render immediately from the summary the list
  /// or Favorites screen already has, even before details load (or when
  /// offline). Everything below comes from [pokemonDetailProvider].
  final PokemonSummary pokemon;

  static Route<void> route(PokemonSummary pokemon) => MaterialPageRoute(
    builder: (context) => PokemonDetailScreen(pokemon: pokemon),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(pokemonDetailProvider(pokemon.id));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(pokemon: pokemon),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NameAndTypes(pokemon: pokemon),
                    const SizedBox(height: 24),
                    switch (detail) {
                      AsyncData(:final value) => _Details(pokemon: value),
                      AsyncError(:final error) => _InlineError(
                        message: ApiException.describe(error),
                        onRetry: () =>
                            ref.invalidate(pokemonDetailProvider(pokemon.id)),
                      ),
                      _ => const Padding(
                        padding: EdgeInsets.all(32),
                        child: LoadingView(),
                      ),
                    },
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact error for inside the scrolling page (the full-screen
/// [ErrorView] would try to fill an unbounded height here).
class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: AppColors.grey200,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.grey600),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

/// Curved type-colored header with back button, heart, symbol and artwork.
class _Header extends StatelessWidget {
  const _Header({required this.pokemon});

  static const double _height = 307;

  /// Bottom of the curved background, measured from the design.
  static const double _curveBottom = 271;
  static const double _imageSize = 190;

  final PokemonSummary pokemon;

  @override
  Widget build(BuildContext context) {
    final type = pokemon.primaryType;
    final topInset = MediaQuery.paddingOf(context).top;
    final width = MediaQuery.sizeOf(context).width;
    // The design's circle is 498px wide on a 360px screen.
    final diameter = width * 498 / 360;

    return SizedBox(
      height: _height + topInset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: topInset + _curveBottom - diameter,
            left: (width - diameter) / 2,
            width: diameter,
            height: diameter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    type.color,
                    Color.lerp(type.color, Colors.white, 0.4)!,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: topInset + 35,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.7),
                  Colors.white.withValues(alpha: 0),
                ],
              ).createShader(bounds),
              child: TypeIcon(type: type, size: 204, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 4,
            child: CachedNetworkImage(
              imageUrl: pokemon.imageUrl,
              width: _imageSize,
              height: _imageSize,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => const Icon(
                Icons.catching_pokemon,
                size: 96,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: topInset + 8,
            left: 4,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'Back',
                  icon: const Icon(Icons.chevron_left, size: 38),
                  color: Colors.white,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                FavoriteButton(
                  pokemon: pokemon,
                  variant: FavoriteButtonVariant.header,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NameAndTypes extends StatelessWidget {
  const _NameAndTypes({required this.pokemon});

  final PokemonSummary pokemon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pokemon.displayName,
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        Text(
          Formatters.pokedexNumber(pokemon.id),
          style: textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final type in pokemon.types) TypeChip(type: type, large: true),
          ],
        ),
      ],
    );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Species data is optional: while loading or on failure, its sections
    // are hidden (or show a dash) instead of blocking the whole screen.
    final speciesAsync = ref.watch(pokemonSpeciesProvider(pokemon.id));
    final species = speciesAsync.hasValue ? speciesAsync.requireValue : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (species?.description case final description?) ...[
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              height: 1.45,
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.grey100),
          const SizedBox(height: 20),
        ],
        _InfoRow(
          left: _InfoCard(
            icon: Icons.scale_outlined,
            label: 'Weight',
            value: Formatters.weight(pokemon.weight),
          ),
          right: _InfoCard(
            icon: Icons.height,
            label: 'Height',
            value: Formatters.height(pokemon.height),
          ),
        ),
        const SizedBox(height: 20),
        _InfoRow(
          left: _InfoCard(
            icon: Icons.category_outlined,
            label: 'Category',
            value: species?.category ?? '—',
          ),
          right: _InfoCard(
            icon: Icons.catching_pokemon,
            label: pokemon.abilities.length == 1 ? 'Ability' : 'Abilities',
            value: pokemon.abilities.join('\n'),
          ),
        ),
        if (species != null) ...[
          const SizedBox(height: 20),
          _GenderBar(species: species),
        ],
        const SizedBox(height: 40),
        _BaseStats(stats: pokemon.stats, type: pokemon.primaryType),
      ],
    );
  }
}

/// Two equal-height info cards side by side, 20px apart.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: 20),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Colors.black.withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: muted),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: textTheme.labelMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.6,
                color: muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black.withValues(alpha: 0.9),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GenderBar extends StatelessWidget {
  const _GenderBar({required this.species});

  static const Color _male = Color(0xFF2551C3);
  static const Color _female = Color(0xFFFF7596);

  final PokemonSpecies species;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.6,
      color: Colors.black.withValues(alpha: 0.7),
    );
    final female = species.femaleRatio;

    return Column(
      children: [
        Text('GENDER', style: labelStyle),
        const SizedBox(height: 12),
        if (female == null)
          Text('Genderless', style: labelStyle)
        else ...[
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(49)),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  if (female < 1)
                    Expanded(
                      flex: ((1 - female) * 1000).round(),
                      child: const ColoredBox(color: _male),
                    ),
                  if (female > 0)
                    Expanded(
                      flex: (female * 1000).round(),
                      child: const ColoredBox(color: _female),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _GenderLabel(
                icon: Icons.male,
                text: _percent(1 - female),
                style: labelStyle,
              ),
              _GenderLabel(
                icon: Icons.female,
                text: _percent(female),
                style: labelStyle,
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 0.875 → "87.5%", 0.5 → "50%".
  static String _percent(double ratio) {
    final value = ratio * 100;
    return '${value == value.roundToDouble() ? value.toInt() : value}%';
  }
}

class _GenderLabel extends StatelessWidget {
  const _GenderLabel({
    required this.icon,
    required this.text,
    required this.style,
  });

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: style?.color),
        const SizedBox(width: 3),
        Text(text, style: style),
      ],
    );
  }
}

/// Not in the Figma design, but required by the assignment. Styled to
/// match the design's section titles and type colors.
class _BaseStats extends StatelessWidget {
  const _BaseStats({required this.stats, required this.type});

  final List<PokemonStat> stats;
  final PokemonType type;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = stats.fold<int>(0, (sum, stat) => sum + stat.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Base Stats',
          style: textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        for (final stat in stats)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: _StatRow(
              label: stat.label,
              value: stat.value,
              color: type.color,
            ),
          ),
        const SizedBox(height: 6),
        _StatRow(label: 'Total', value: total, color: null),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;

  /// Bar color; `null` hides the bar (used for the total).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final barColor = color;

    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$value',
            textAlign: TextAlign.end,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: barColor == null ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (barColor != null)
          Expanded(
            // Bars grow in when the screen opens.
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value / PokemonStat.maxValue),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, progress, child) => LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: barColor,
                backgroundColor: AppColors.grey100,
                borderRadius: const BorderRadius.all(Radius.circular(49)),
              ),
            ),
          ),
      ],
    );
  }
}
