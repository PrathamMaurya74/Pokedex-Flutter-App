import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Pokéball tab icon from the design: a grey outline when inactive, and
/// red/white with a blue outline when active.
class PokeballIcon extends StatelessWidget {
  const PokeballIcon({super.key, required this.active, this.size = 26});

  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _PokeballPainter(active: active),
    );
  }
}

class _PokeballPainter extends CustomPainter {
  const _PokeballPainter({required this.active});

  static const Color _red = Color(0xFFE53935);

  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.075;
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - stroke / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final outline = Paint()
      ..color = active ? AppColors.primary : AppColors.grey500
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    if (active) {
      canvas
        ..drawArc(rect, math.pi, math.pi, true, Paint()..color = _red)
        ..drawArc(rect, 0, math.pi, true, Paint()..color = Colors.white);
    }

    final innerRadius = radius * 0.32;
    canvas
      ..drawCircle(center, radius, outline)
      ..drawLine(
        Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy),
        outline,
      )
      // Inner button covers the middle of the line.
      ..drawCircle(center, innerRadius, Paint()..color = Colors.white)
      ..drawCircle(center, innerRadius, outline);
  }

  @override
  bool shouldRepaint(_PokeballPainter oldDelegate) =>
      oldDelegate.active != active;
}
