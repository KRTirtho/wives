import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/models/persisted_change_notifier.dart';

class PreferencesProvider extends PersistedChangeNotifier {
  final Ref ref;

  double fontSize;
  String? defaultShell;
  String? defaultWorkingDirectory;
  PreferencesProvider(
    this.ref, {
    required this.fontSize,
    this.defaultShell,
    this.defaultWorkingDirectory,
  }) : super();

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

  @override
  FutureOr<void> loadFromLocal(Map<String, dynamic> map) {
    fontSize = map['fontSize'] ?? fontSize;
    defaultShell = map['defaultShell'] ?? defaultShell;
    defaultWorkingDirectory =
        map['defaultWorkingDirectory'] ?? defaultWorkingDirectory;
  }

  @override
  FutureOr<Map<String, dynamic>> toMap() {
    return {
      'fontSize': fontSize,
      'defaultShell': defaultShell,
      'defaultWorkingDirectory': defaultWorkingDirectory,
    };
  }
}

final preferencesProvider = ChangeNotifierProvider(
  (ref) {
    return PreferencesProvider(ref, fontSize: 16);
  },
);
