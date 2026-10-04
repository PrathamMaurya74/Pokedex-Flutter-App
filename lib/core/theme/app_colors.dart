import 'package:flutter/material.dart';

/// Base palette taken from the Figma design tokens.
abstract final class AppColors {
  /// "Azul/Normal" – active tab, primary actions.
  static const Color primary = Color(0xFF173EA5);

  /// "Vermelho" – destructive actions (swipe-to-remove background).
  static const Color favorite = Color(0xFFCD3131);

  /// Filled heart color used by the design's "Fav" icons.
  static const Color heart = Color(0xFFFF5A5F);

  /// "Preto" – main text.
  static const Color textPrimary = Color(0xFF000000);

  /// "Escala de cinza" greys, from darkest to lightest.
  static const Color grey800 = Color(0xFF333333);
  static const Color grey600 = Color(0xFF666666);
  static const Color grey500 = Color(0xFF808080);
  static const Color grey400 = Color(0xFF999999);
  static const Color grey200 = Color(0xFFCCCCCC);
  static const Color grey100 = Color(0xFFE6E6E6);
  static const Color grey50 = Color(0xFFF2F2F2);

  static const Color background = Color(0xFFFFFFFF);
}
