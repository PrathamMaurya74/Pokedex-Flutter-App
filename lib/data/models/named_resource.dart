/// A `{ "name": ..., "url": ... }` entry from a PokéAPI list response.
class NamedResource {
  const NamedResource({required this.name, required this.url});

  factory NamedResource.fromJson(Map<String, dynamic> json) =>
      NamedResource(name: json['name'] as String, url: json['url'] as String);

  final String name;
  final String url;

  /// Extracts the ID from a URL like `.../pokemon/25/` → `25`.
  int get id {
    final segments = Uri.parse(url).pathSegments.where((s) => s.isNotEmpty);
    return int.parse(segments.last);
  }
}
