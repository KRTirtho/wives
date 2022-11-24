import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:wives/providers/terminal_tree.dart';
import 'package:xterm/core.dart';
import 'package:xterm/src/ui/input_map.dart';

enum CursorSelectorType {
  selectLeft,
  selectRight,
  clearLeft,
  clearRight,
}

class CursorSelectorIntent extends Intent {
  final TerminalNode node;
  final CursorSelectorType direction;
  const CursorSelectorIntent(this.node,
      {this.direction = CursorSelectorType.selectRight});
}

class CursorSelectorAction extends Action<CursorSelectorIntent> {
  @override
  invoke(CursorSelectorIntent intent) {
    final terminal = intent.node;
    final cursorX = terminal.terminal.buffer.cursorX;
    final cursorY = terminal.terminal.buffer.cursorY;
    final selectionBegin = terminal.controller.selection?.begin;
    final selectionEnd = terminal.controller.selection?.end;
    final content = terminal.terminal.mainBuffer.currentLine.getText().trim();
    final contentCursorX = content.trim().length + 1;

    switch (intent.direction) {
      case CursorSelectorType.selectRight:
        {
          if (cursorX + 2 > contentCursorX) break;
          terminal.controller.setSelection(
            BufferRangeBlock(
              CellOffset(selectionBegin?.x ?? cursorX, cursorY),
              CellOffset(
                cursorX + 1,
                cursorY,
              ),
            ),
          );
          terminal.terminal.moveCursorX(1);
          break;
        }
      case CursorSelectorType.selectLeft:
        {
          terminal.controller.setSelection(
            BufferRangeBlock(
              CellOffset(selectionEnd?.x ?? cursorX, cursorY),
              CellOffset(
                cursorX > 0 ? cursorX - 1 : cursorX,
                cursorY,
              ),
            ),
          );
          terminal.terminal.moveCursorX(-1);
          break;
        }
      case CursorSelectorType.clearLeft:
        {
          terminal.controller.clearSelection();

          if (cursorX > contentCursorX) {
            terminal.terminal.setCursorX(contentCursorX);
          }
          terminal.terminal.keyInput(
            keyToTerminalKey(LogicalKeyboardKey.arrowLeft)!,
          );
          break;
        }
      case CursorSelectorType.clearRight:
        {
          terminal.controller.clearSelection();
          if (cursorX > contentCursorX) {
            terminal.terminal.setCursorX(contentCursorX);
          }
          terminal.terminal.keyInput(
            keyToTerminalKey(LogicalKeyboardKey.arrowRight)!,
          );
          break;
        }
    }

    return null;
  }
}
