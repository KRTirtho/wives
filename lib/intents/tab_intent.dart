import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:wives/providers/TerminalTree.dart';
import 'package:wives/routes.dart';

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
  final String? shell;
  const TabIntent({
    required this.ref,
    required this.controller,
    required this.intentType,
    this.shell,
  });
}

class TabAction extends Action<TabIntent> {
  @override
  void invoke(intent) {
    if (router.location != "/") return;
    final terminal = intent.ref.read(TerminalTree.provider);
    switch (intent.intentType) {
      case TabIntentType.create:
        terminal.createNewTerminalTab(intent.shell);
        intent.controller.scrollToIndex(
          terminal.activeIndex!,
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
