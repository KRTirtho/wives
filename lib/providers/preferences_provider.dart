import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/providers/terminal_theme_provider.dart';
import 'package:wives/models/persisted_change_notifier.dart';
import 'package:xterm/ui.dart';

const fontFamilies = [
  "Jetbrains Mono",
  "Ubuntu Mono",
  "Fira Mono",
  "Cascadia Mono",
  "Monoton",
  "NotoSans Mono",
  "Redhat Mono",
];

class PreferencesProvider extends PersistedChangeNotifier {
  final Ref ref;

  double fontSize;
  String? defaultShell;
  String? defaultWorkingDirectory;
  String fontFamily;
  bool? checkUpdate;
  ThemeMode themeMode;

  MapEntry<String, TerminalTheme> defaultTheme =
      const MapEntry("Default", TerminalThemes.defaultTheme);

  PreferencesProvider(
    this.ref, {
    required this.fontSize,
    this.fontFamily = "Jetbrains Mono",
    this.defaultShell,
    this.defaultWorkingDirectory,
    this.checkUpdate,
    this.themeMode = ThemeMode.dark,
  }) : super();

  bool get isDark => themeMode == ThemeMode.dark;
  bool get isLight => themeMode == ThemeMode.light;

  void setFontSize(double newFontSize) {
    if (newFontSize < 5 || newFontSize > 70) return;
    fontSize = newFontSize;
    notifyListeners();
    updatePersistence();
  }

  void setDefaultShell(String shell) {
    defaultShell = shell;
    notifyListeners();
    updatePersistence();
  }

  void setDefaultWorkingDirectory(String dir) {
    defaultWorkingDirectory = dir;
    notifyListeners();
    updatePersistence();
  }

  void setFontFamily(String family) {
    fontFamily = family;
    notifyListeners();
    updatePersistence();
  }

  void setDefaultTheme(MapEntry<String, TerminalTheme> theme) {
    defaultTheme = theme;
    notifyListeners();
    updatePersistence();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
    updatePersistence();
  }

  void setCheckUpdate(bool value) {
    checkUpdate = value;
    notifyListeners();
    updatePersistence();
  }

  void setAlwaysExitOnCloseLastTab(bool value) {
    notifyListeners();
    updatePersistence();
  }

  @override
  FutureOr<void> loadFromLocal(Map<String, dynamic> map) {
    fontSize = map['fontSize'] ?? fontSize;
    defaultShell = map['defaultShell'] ?? defaultShell;
    defaultWorkingDirectory =
        map['defaultWorkingDirectory'] ?? defaultWorkingDirectory;
    fontFamily = map['fontFamily'] ?? fontFamily;

    if (map['defaultTheme'] != null) {
      final decodedTheme = jsonDecode(map['defaultTheme']);
      defaultTheme = MapEntry(
        decodedTheme['name'],
        TerminalThemeJson.fromJson(decodedTheme['theme']),
      );
    }

    if (map['themeMode'] != null) {
      themeMode = ThemeMode.values.firstWhere(
        (element) => element.name == map['themeMode'],
      );
    }

    checkUpdate = map['checkUpdate'] ?? checkUpdate;
  }

  @override
  FutureOr<Map<String, dynamic>> toMap() {
    return {
      'checkUpdate': checkUpdate,
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'defaultShell': defaultShell,
      'defaultWorkingDirectory': defaultWorkingDirectory,
      'defaultTheme': jsonEncode({
        "name": defaultTheme.key,
        "theme": defaultTheme.value.toJson(),
      }),
      'themeMode': themeMode.name,
    };
  }
}

final preferencesProvider = ChangeNotifierProvider(
  (ref) {
    return PreferencesProvider(ref, fontSize: 16);
  },
);
