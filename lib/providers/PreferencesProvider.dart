import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PreferencesProvider extends ChangeNotifier {
  double fontSize;
  PreferencesProvider({
    required this.fontSize,
  }) : super();

  void setFontSize(double newFontSize) {
    if (newFontSize < 5 || newFontSize > 70) return;
    fontSize = newFontSize;
    notifyListeners();
  }
}

final preferencesProvider = ChangeNotifierProvider(
  (ref) {
    return PreferencesProvider(fontSize: 16);
  },
);
