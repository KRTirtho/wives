import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PreferencesProvider extends ChangeNotifier {
  double fontSize;
  String? defaultShell;
  String? defaultWorkingDirectory;
  PreferencesProvider({
    required this.fontSize,
    this.defaultShell,
    this.defaultWorkingDirectory,
  }) : super();

  void setFontSize(double newFontSize) {
    if (newFontSize < 5 || newFontSize > 70) return;
    fontSize = newFontSize;
    notifyListeners();
  }

  void setDefaultShell(String shell) {
    defaultShell = shell;
    notifyListeners();
  }

  void setDefaultWorkingDirectory(String dir) {
    defaultWorkingDirectory = dir;
    notifyListeners();
  }
}

final preferencesProvider = ChangeNotifierProvider(
  (ref) {
    return PreferencesProvider(fontSize: 16);
  },
);
