import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/providers/TerminalTree.dart';

enum SplitViewIntentType {
  splitHorizontal,
  splitVertical,
  focusNext,
  close,
}

class SplitViewIntent extends Intent {
  final WidgetRef ref;
  final SplitViewIntentType intentType;
  final TerminalNode? node;

  const SplitViewIntent({
    required this.ref,
    required this.intentType,
    this.node,
  });
}

class SplitViewAction extends Action<SplitViewIntent> {
  @override
  void invoke(intent) {
    final terminal =
        intent.node ?? intent.ref.read(TerminalTree.provider).focused;
    switch (intent.intentType) {
      case SplitViewIntentType.splitHorizontal:
        terminal?.split(TerminalAxis.row);
        break;
      case SplitViewIntentType.splitVertical:
        terminal?.split(TerminalAxis.column);
        break;
      case SplitViewIntentType.close:
        final parent = terminal?.parent;
        parent?.removeChild(terminal!);
        break;
      case SplitViewIntentType.focusNext:
        terminal?.focusNode.nextFocus();
        break;
      default:
    }
  }
}
