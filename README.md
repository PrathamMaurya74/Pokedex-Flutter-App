# Pok-dex-Flutter-App
A Flutter Pokédex app using PokéAPI to browse, search, and view detailed Pokémon information, with locally stored favorites synchronized in real time across screens.

Assumptions:
Search only filters loaded Pokémon, as the spec states, so auto-loading is paused while a search is active.
The list endpoint has no type data, so list cards show name, image, and ID as the minimum requires. Type-colored list cards would need one detail call per card, which we can add as an optional enhancement.
