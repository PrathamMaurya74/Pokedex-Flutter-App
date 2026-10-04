import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/local/favorites_storage.dart';
import 'state/core_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The assignment only requires portrait mode on phones.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Load saved favorites into memory once, before the first frame, so
  // they are available synchronously and the hearts never flicker.
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: {FavoritesStorage.storageKey},
    ),
  );

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const PokedexApp(),
    ),
  );
}
