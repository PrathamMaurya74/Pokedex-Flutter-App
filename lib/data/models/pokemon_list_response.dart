import 'named_resource.dart';

/// Raw response of `GET /pokemon?limit=&offset=`.
class PokemonListResponse {
  const PokemonListResponse({required this.results, this.next});

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) =>
      PokemonListResponse(
        next: json['next'] as String?,
        results: (json['results'] as List<dynamic>)
            .map((e) => NamedResource.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final List<NamedResource> results;

  /// URL of the next page, or `null` on the last page.
  final String? next;
}
