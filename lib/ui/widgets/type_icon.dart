import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/pokemon_type.dart';

/// A type's symbol from the design, tinted with any [color].
class TypeIcon extends StatelessWidget {
  const TypeIcon({
    super.key,
    required this.type,
    required this.size,
    required this.color,
  });

  final PokemonType type;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      type.iconAsset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
