import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PaletteAction {
  final String title;
  final String? description;
  final IconData icon;
  final bool closeAfterClick;
  final SingleActivator? shortcut;
  final FutureOr<void> Function(BuildContext context, WidgetRef ref) onInvoke;

  PaletteAction({
    required this.title,
    this.description,
    required this.icon,
    required this.onInvoke,
    this.shortcut,
    this.closeAfterClick = true,
  });
}
