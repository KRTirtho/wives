import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:xterm/core.dart';
import 'package:xterm/ui.dart';

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
      tab.paste(data.text!);
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
