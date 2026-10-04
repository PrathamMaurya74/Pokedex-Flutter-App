# Pokédex Flutter App

A Flutter app based on the [Pokédex / Pokémon App](https://www.figma.com/community/file/1202971127473077147/pokedex-pokemon-app) Figma design, using live data from [PokéAPI](https://pokeapi.co). The design is in Portuguese, so I translated all text to English.

The app has three screens:

- Pokédex list with infinite scroll and search by name
- Pokémon detail with types, description, weight, height, category, abilities, gender ratio and base stats
- Favorites, which updates live and supports swipe to remove

Favorites are saved on the device and stay in sync across all screens.

## Running the app

You need Flutter (stable channel, Dart 3). I built and tested it on Android in portrait mode.

```bash
git clone https://github.com/PrathamMaurya74/Pokedex-Flutter-App.git
cd Pokedex-Flutter-App
flutter pub get
flutter run
```

`dart format .` and `flutter analyze` both pass with no issues.

## Folder structure

```
lib/
  main.dart            app startup (portrait lock, loads saved favorites)
  app.dart             MaterialApp and theme
  core/                constants, errors, theme, formatters
  data/
    models/            Pokemon, PokemonSummary, PokemonSpecies, etc.
    services/          PokeApiService (HTTP requests and JSON parsing)
    repositories/      PokemonRepository (parallel loading and caching)
    local/             FavoritesStorage (shared_preferences)
  state/               Riverpod providers
  ui/
    screens/           tabs, list, detail, favorites
    widgets/           card, favorite button, type chip, search field, etc.
assets/
  types/               18 type icons exported from the Figma file
  images/              empty favorites illustration
```

The UI only talks to providers, providers talk to the repository, and the repository talks to the API service. Widgets never deal with HTTP, JSON or storage directly.

## State management

I used Riverpod.

The main requirement was that favorites have one source of truth shared by every screen. With Riverpod this is simple: `favoritesProvider` holds a map of favorite Pokémon, and every heart icon, the Favorites tab and the detail screen watch it. When a favorite is toggled anywhere, the provider updates once and every screen watching it rebuilds. No screen keeps its own copy, so they can't get out of sync, and I didn't need callbacks or refresh logic between screens.

Each heart uses `select()` to watch only its own Pokémon, so toggling one favorite rebuilds one heart instead of the whole list.

`AsyncValue` also made the loading, error and data states easy to handle on the list and detail screens.

I chose Riverpod over Provider because it doesn't depend on `BuildContext`, and over BLoC because it needs much less boilerplate for an app this size. The search text is plain widget state, since only the list screen uses it.

## Local storage

I used `shared_preferences` (the `SharedPreferencesWithCache` API) and save favorites as a JSON list.

The data is small, so a key-value store is enough. Hive or sqflite would add setup without any real benefit here. Preferences are loaded once in `main()` before the app starts, so saved favorites are available immediately and the hearts don't flicker on launch.

For each favorite I store the id, name, image URL and types. That is everything a card needs, so the Favorites tab works offline without any API calls.

When a favorite is toggled, the UI updates first and then the change is saved. If saving fails, the change is reverted and a message is shown.

## Loading data

- Pagination uses the `next` URL returned by the API. The next page starts loading shortly before you reach the end of the list.
- The list endpoint only returns names and URLs, but the cards in the design show types. So for each page I fetch the 20 Pokémon details in parallel.
- The repository caches these responses in memory. Opening a Pokémon from the list doesn't make another request, and failed requests aren't cached so retrying works.
- JSON is decoded in a background isolate because some detail responses are large and decoding them on the main thread can cause stutter while scrolling.
- Images are cached with `cached_network_image` and decoded at display size.

## Error handling and edge cases

- First page fails to load: full screen error with a Try again button.
- A later page fails: the already loaded Pokémon stay on screen and a retry button appears at the bottom. Scrolling doesn't keep retrying automatically.
- Detail fails (for example when offline): the header, name and types still show, and only the details section shows an error with retry.
- Species data (description, category, gender) fails: those parts are hidden and the rest of the screen works normally.
- Search with no results: a message explains that only loaded Pokémon are searched, with a button to load more.
- No favorites: empty state with the illustration from the design.

All network errors are converted into one `ApiException` type with a readable message, so the UI doesn't handle raw exceptions.

## Packages

- `flutter_riverpod`: state management
- `http`: API requests (only simple GET requests, so I didn't need `dio`)
- `shared_preferences`: saving favorites
- `cached_network_image`: image caching
- `flutter_svg`: type icons from the design
- `google_fonts`: Poppins, the font used in the design

## Differences from the design

- All text is in English.
- I added a Base Stats section to the detail screen because the assignment requires it. It isn't in the design, so I styled it to match the other sections.
- Only the Pokédex and Favorites tabs are included. Regions and Account need features that are outside this assignment, like login.
- I used the official artwork instead of the pixel sprites from the design.
- The Pokéball tab icon is drawn in code, and the empty favorites illustration is a grey version of the official Magikarp artwork.

## Assumptions

- Search only filters the Pokémon that are already loaded, as described in the assignment. Automatic loading pauses while searching so the results don't change unexpectedly.
- Favorites are sorted by Pokédex number, like in the design.
- A Pokémon's first type decides its card and header color.

## Known limitations and future improvements

- The Weaknesses and Evolutions sections from the design are not implemented. They need extra endpoints (type matchups and evolution chains).
- The type filter and sort buttons from the design header are not implemented.
- Search only covers loaded Pokémon. I would load the full list of names once so search can find any Pokémon.
- Each page makes 20 detail requests to show types on the cards. PokéAPI's GraphQL endpoint could get names and types in a single request.
- No automated tests, since they were out of scope. The favorites logic and the repository are set up so they could be tested by swapping in a fake storage or HTTP client.

## Credits

- Design: [Pokédex / Pokémon App](https://www.figma.com/community/file/1202971127473077147/pokedex-pokemon-app) by Junior Saraiva, licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). The type icons were exported from this file.
- Data and artwork: [PokéAPI](https://pokeapi.co) and the [PokeAPI/sprites](https://github.com/PokeAPI/sprites) repository.
- Pokémon and Pokémon character names are trademarks of Nintendo, Creatures Inc. and GAME FREAK inc. This is a non-commercial project made for an assignment.
