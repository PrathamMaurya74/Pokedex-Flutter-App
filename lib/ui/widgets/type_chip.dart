import 'package:flutter/material.dart';

import '../../core/theme/pokemon_type.dart';
import 'type_icon.dart';

/// Rounded type badge: white circle with the type symbol, then the label.
class TypeChip extends StatelessWidget {
  const TypeChip({super.key, required this.type, this.large = false});

  final PokemonType type;

  /// Small chips are used on cards, large ones on the detail screen.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final circleSize = large ? 28.0 : 20.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 6,
        vertical: large ? 4 : 3,
      ),
      decoration: ShapeDecoration(
        color: type.color,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: TypeIcon(
              type: type,
              size: circleSize * 0.6,
              color: type.color,
            ),
          ),
          SizedBox(width: large ? 8 : 6),
          Text(
            type.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: large ? 14 : 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
              color: type.onColor,
            ),
          ),
        ],
      ),
    );
  }
}
