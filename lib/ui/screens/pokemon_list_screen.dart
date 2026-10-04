import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../state/pokemon_list_provider.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_detail_screen.dart';
import '../widgets/search_field.dart';
import '../widgets/state_views.dart';

class PokemonListScreen extends ConsumerStatefulWidget {
  const PokemonListScreen({super.key});

  @override
  ConsumerState<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends ConsumerState<PokemonListScreen> {
  /// Start loading the next page this many pixels before the end.
  static const double _loadMoreThreshold = 600;

  final _searchController = TextEditingController();

  /// Search is local UI state: only this screen uses it, so it doesn't
  /// need a provider. Stored lowercased and trimmed.
  String _query = '';

  bool get _isSearching => _query.isNotEmpty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMore() => ref.read(pokemonListProvider.notifier).loadMore();

  bool _onScroll(ScrollNotification notification) {
    final listState = ref.read(pokemonListProvider);
    final hasLoadError =
        listState.hasValue && listState.requireValue.loadMoreError != null;

    // Search filters only what is loaded (per the spec), so auto-loading
    // pauses while searching. After a failure, wait for a manual retry
    // instead of hammering the API on every scroll event.
    if (!_isSearching &&
        !hasLoadError &&
        notification.metrics.axis == Axis.vertical &&
        notification.metrics.extentAfter < _loadMoreThreshold) {
      _loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(pokemonListProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              child: SearchField(
                controller: _searchController,
                onChanged: (value) => setState(() {
                  _query = value.trim().toLowerCase();
                }),
              ),
            ),
            Expanded(
              child: switch (listState) {
                AsyncData(:final value) => _buildList(value),
                AsyncError(:final error) => ErrorView(
                  message: ApiException.describe(error),
                  onRetry: () => ref.invalidate(pokemonListProvider),
                ),
                _ => const LoadingView(),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(PokemonListState state) {
    final visible = _isSearching
        ? state.items
              .where((p) => p.displayName.toLowerCase().contains(_query))
              .toList()
        : state.items;

    if (visible.isEmpty) {
      return EmptyView(
        icon: Icons.search_off_rounded,
        title: 'No Pokémon found',
        message:
            'Nothing matches "${_searchController.text.trim()}" in the '
            '${state.items.length} Pokémon loaded so far.',
        actionLabel: state.hasMore ? 'Load more Pokémon' : null,
        onAction: state.hasMore ? _loadMore : null,
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: visible.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == visible.length) {
            return _ListFooter(
              state: state,
              isSearching: _isSearching,
              onLoadMore: _loadMore,
            );
          }
          final pokemon = visible[index].summary;
          return PokemonCard(
            key: ValueKey(pokemon.id),
            pokemon: pokemon,
            onTap: () =>
                Navigator.of(context).push(PokemonDetailScreen.route(pokemon)),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.grey50)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: child,
      ),
    );
  }
}

/// Last list item: loading spinner, inline error, or a search hint.
class _ListFooter extends StatelessWidget {
  const _ListFooter({
    required this.state,
    required this.isSearching,
    required this.onLoadMore,
  });

  final PokemonListState state;
  final bool isSearching;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.grey600);

    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.loadMoreError case final error?) {
      return Column(
        children: [
          Text(
            ApiException.describe(error),
            textAlign: TextAlign.center,
            style: textStyle,
          ),
          TextButton(onPressed: onLoadMore, child: const Text('Try again')),
        ],
      );
    }

    if (isSearching && state.hasMore) {
      return Column(
        children: [
          Text(
            'Searching the ${state.items.length} Pokémon loaded so far.',
            textAlign: TextAlign.center,
            style: textStyle,
          ),
          TextButton(
            onPressed: onLoadMore,
            child: const Text('Load more Pokémon'),
          ),
        ],
      );
    }

    if (!state.hasMore) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "You've reached the end of the Pokédex.",
          textAlign: TextAlign.center,
          style: textStyle,
        ),
      );
    }

    return const SizedBox(height: 16);
  }
}
