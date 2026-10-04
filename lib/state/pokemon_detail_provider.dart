import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/pokemon.dart';
import '../data/models/pokemon_species.dart';
import 'core_providers.dart';

/// Full details for one Pokémon. Instant for anything already loaded in
/// the list, thanks to the repository cache. Disposed when the detail
/// screen closes.
final pokemonDetailProvider = FutureProvider.autoDispose.family<Pokemon, int>(
  (ref, id) => ref.watch(pokemonRepositoryProvider).getPokemon(id),
);

/// Optional extras (description, category, gender). If this fails, the
/// detail screen simply hides those sections.
final pokemonSpeciesProvider = FutureProvider.autoDispose
    .family<PokemonSpecies, int>(
      (ref, id) => ref.watch(pokemonRepositoryProvider).getSpecies(id),
    );
