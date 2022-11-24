import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/providers/preferences_provider.dart';

class FontAdjustmentIntent extends Intent {
  final WidgetRef ref;
  final int adjustment;
  const FontAdjustmentIntent({
    required this.ref,
    required this.adjustment,
  });
}

class FontAdjustmentAction extends Action<FontAdjustmentIntent> {
  @override
  void invoke(intent) {
    final preferences = intent.ref.read(preferencesProvider);
    preferences.setFontSize(preferences.fontSize + intent.adjustment);
  }
}
