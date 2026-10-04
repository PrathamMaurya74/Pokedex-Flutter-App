import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/pokeball_icon.dart';
import 'favorites_screen.dart';
import 'pokemon_list_screen.dart';

/// Bottom tab bar from the design. Only the Pokédex and Favorites tabs are
/// built; Regions and Account depend on features outside this assignment.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _select(int index) => setState(() {
    _index = index;
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Android back on the Favorites tab returns to the Pokédex first.
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        // IndexedStack keeps both tabs alive, so the Pokédex keeps its
        // scroll position and loaded pages when switching tabs.
        body: IndexedStack(
          index: _index,
          children: const [PokemonListScreen(), FavoritesScreen()],
        ),
        bottomNavigationBar: _TabBar(currentIndex: _index, onSelected: _select),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.currentIndex, required this.onSelected});

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.grey100)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              _TabItem(
                label: 'Pokédex',
                selected: currentIndex == 0,
                onTap: () => onSelected(0),
                icon: (active) => PokeballIcon(active: active),
              ),
              _TabItem(
                label: 'Favorites',
                selected: currentIndex == 1,
                onTap: () => onSelected(1),
                icon: (active) => Icon(
                  active ? Icons.favorite : Icons.favorite_border,
                  size: 26,
                  color: active ? AppColors.heart : AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget Function(bool active) icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon(selected),
              // As in the design, only the active tab shows its label.
              if (selected)
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
