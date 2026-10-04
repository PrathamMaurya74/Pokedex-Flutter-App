import 'package:flutter/material.dart';

/// All 18 Pokémon types with the colors from the Figma "Elementos" tokens.
///
/// Enum names match PokéAPI type names exactly (`fire`, `water`, ...),
/// so API strings map directly with [PokemonType.fromApiName], and icon
/// files in `assets/types/` are named the same way.
enum PokemonType {
  normal('Normal', Color(0xFF919AA2), Colors.black),
  fire('Fire', Color(0xFFFF9D55), Colors.black),
  water('Water', Color(0xFF5090D6), Colors.black),
  electric('Electric', Color(0xFFF4D23C), Colors.black),
  grass('Grass', Color(0xFF63BC5A), Colors.black),
  ice('Ice', Color(0xFF73CEC0), Colors.black),
  fighting('Fighting', Color(0xFFCE416B), Colors.white),
  poison('Poison', Color(0xFFB567CE), Colors.black),
  ground('Ground', Color(0xFFD97845), Colors.black),
  flying('Flying', Color(0xFF89AAE3), Colors.black),
  psychic('Psychic', Color(0xFFFA7179), Colors.black),
  bug('Bug', Color(0xFF91C12F), Colors.black),
  rock('Rock', Color(0xFFC5B78C), Colors.black),
  ghost('Ghost', Color(0xFF5269AD), Colors.white),
  dragon('Dragon', Color(0xFF0B6DC3), Colors.white),
  dark('Dark', Color(0xFF5A5465), Colors.white),
  steel('Steel', Color(0xFF5A8EA2), Colors.black),
  fairy('Fairy', Color(0xFFEC8FE6), Colors.black);

  const PokemonType(this.label, this.color, this.onColor);

  /// English display label.
  final String label;

  /// Background color for chips and artwork panels.
  final Color color;

  /// Text color that stays readable on top of [color].
  final Color onColor;

  /// Very light tint used as the card background (e.g. #FCF3EB for fire).
  Color get tint => Color.lerp(Colors.white, color, 0.12)!;

  String get iconAsset => 'assets/types/$name.svg';

  /// Converts a PokéAPI type name (e.g. `"fire"`) to a [PokemonType].
  /// Falls back to [PokemonType.normal] for unknown values.
  static PokemonType fromApiName(String name) =>
      values.asNameMap()[name] ?? PokemonType.normal;
}
