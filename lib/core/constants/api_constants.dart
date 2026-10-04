abstract final class ApiConstants {
  static const String baseUrl = 'https://pokeapi.co/api/v2';
  static const int pageSize = 20;
  static const Duration requestTimeout = Duration(seconds: 15);

  /// The list endpoint returns only name + url, so the artwork URL is built
  /// from the ID instead of making one extra request per card.
  static String artworkUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/'
      'pokemon/other/official-artwork/$id.png';
}
