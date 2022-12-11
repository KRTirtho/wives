import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class TerminalShortcutActivator extends SingleActivator {
  TerminalShortcutActivator(
    LogicalKeyboardKey trigger, {
    bool control = false,
    bool alt = false,
    bool shift = false,
  }) : super(
          control: !Platform.isMacOS && control,
          meta: Platform.isMacOS && control,
          alt: alt,
          shift: shift,
          trigger,
        );

  factory TerminalShortcutActivator.deterministic(
      Set<LogicalKeyboardKey> keys) {
    final control = keys.contains(LogicalKeyboardKey.control) ||
        keys.contains(LogicalKeyboardKey.meta);
    final alt = keys.contains(LogicalKeyboardKey.alt);
    final shift = keys.contains(LogicalKeyboardKey.shift);
    final modifiers = [
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.meta,
      LogicalKeyboardKey.alt,
      LogicalKeyboardKey.shift,
    ];
    final trigger = keys.firstWhere(
      (element) {
        return !modifiers.contains(element);
      },
    );
    return TerminalShortcutActivator(
      trigger,
      control: control,
      alt: alt,
      shift: shift,
    );
  }

  List<LogicalKeyboardKey> get withModifierKeys => [
        if (control) LogicalKeyboardKey.control,
        if (meta) LogicalKeyboardKey.meta,
        if (shift) LogicalKeyboardKey.shift,
        if (alt) LogicalKeyboardKey.alt,
        ...triggers,
      ];

  factory TerminalShortcutActivator.fromJson(Map<String, dynamic> json) {
    return TerminalShortcutActivator(
      LogicalKeyboardKey.findKeyByKeyId(json['trigger'])!,
      control: json['control'] ?? false,
      alt: json['alt'] ?? false,
      shift: json['shift'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "trigger": trigger.keyId,
      "control": control,
      "alt": alt,
      "shift": shift,
    };
  }
}
