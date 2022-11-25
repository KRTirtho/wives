import 'package:flutter/cupertino.dart';

extension Lighting on Color {
  Brightness get brightness {
    return (0.299 * red) + (0.587 * green) + (0.114 * blue) > 128
        ? Brightness.light
        : Brightness.dark;
  }

  bool get isLight {
    return brightness == Brightness.light;
  }

  bool get isDark {
    return brightness == Brightness.dark;
  }

  /// Darken a color by [percent] amount (100 = black)
  // ........................................................
  Color darken([int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(
        alpha, (red * f).round(), (green * f).round(), (blue * f).round());
  }

  /// Lighten a color by [percent] amount (100 = white)
  // ........................................................
  Color lighten([int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var p = percent / 100;
    return Color.fromARGB(alpha, red + ((255 - red) * p).round(),
        green + ((255 - green) * p).round(), blue + ((255 - blue) * p).round());
  }
}
