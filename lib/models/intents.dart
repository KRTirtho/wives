import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:wives/providers/PreferencesProvider.dart';
import 'package:wives/providers/TerminalProvider.dart';
import 'package:wives/routes.dart';
import 'package:xterm/xterm.dart';

enum TabIntentType {
  create,
  close,
  cycleForward,
  cycleBackward,
}

class TabIntent extends Intent {
  final WidgetRef ref;
  final AutoScrollController controller;
  final TabIntentType intentType;
  const TabIntent({
    required this.ref,
    required this.controller,
    required this.intentType,
  });
}

class TabAction extends Action<TabIntent> {
  @override
  void invoke(intent) {
    final terminal = intent.ref.read(terminalProvider);
    switch (intent.intentType) {
      case TabIntentType.create:
        intent.controller.scrollToIndex(
          terminal.createTerminalTab(),
          preferPosition: AutoScrollPosition.begin,
        );
        break;
      case TabIntentType.cycleForward:
        intent.controller.scrollToIndex(
          terminal.cycleForwardTerminalTab(),
          preferPosition: AutoScrollPosition.end,
        );
        break;
      case TabIntentType.cycleBackward:
        intent.controller.scrollToIndex(
          terminal.cycleBackwardTerminalTab(),
          preferPosition: AutoScrollPosition.end,
        );
        break;
      case TabIntentType.close:
        terminal.closeTerminalTab();
        break;
      default:
    }
  }
}

class NavigationIntent extends Intent {
  final String path;
  const NavigationIntent({
    required this.path,
  });
}

class NavigationAction extends Action<NavigationIntent> {
  @override
  void invoke(intent) {
    router.push("/settings");
  }
}

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

class PaletteIntent extends Intent {
  const PaletteIntent();
}

enum CopyPasteIntentType {
  copy,
  paste,
}

class CopyPasteIntent extends Intent {
  final Terminal terminal;
  final CopyPasteIntentType intentType;
  final TerminalController controller;
  const CopyPasteIntent(
    this.terminal, {
    required this.intentType,
    required this.controller,
  });
}

class CopyPasteAction extends Action<CopyPasteIntent> {
  Future<void> copy(CopyPasteIntent intent) async {
    final tab = intent.terminal;
    final text = tab.buffer.getText(intent.controller.selection);
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> paste(CopyPasteIntent intent) async {
    final tab = intent.terminal;
    final data = await Clipboard.getData("text/plain");
    if (data?.text != null && data!.text!.isNotEmpty) {
      tab.write(data.text!);
    }
  }

  @override
  void invoke(intent) async {
    switch (intent.intentType) {
      case CopyPasteIntentType.copy:
        await copy(intent);
        break;
      case CopyPasteIntentType.paste:
        await paste(intent);
        break;
      default:
    }
  }
}

class SearchIntent extends Intent {}
