import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pokemon_summary.dart';

/// Persists favorites on the device as one JSON list in shared_preferences.
class FavoritesStorage {
  const FavoritesStorage(this._prefs);

  static const String storageKey = 'favorite_pokemon';

  final SharedPreferencesWithCache _prefs;

  /// Reads synchronously from the in-memory cache loaded at startup.
  List<PokemonSummary> load() {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return [];

    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => PokemonSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      // Corrupted data shouldn't crash the app; start with no favorites.
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> save(Iterable<PokemonSummary> favorites) => _prefs.setString(
    storageKey,
    jsonEncode(favorites.map((favorite) => favorite.toJson()).toList()),
  );
}
