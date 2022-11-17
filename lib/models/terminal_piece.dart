import 'package:flutter/cupertino.dart';
import 'package:wives/models/constants.dart';
import 'package:xterm/xterm.dart';

class TerminalPiece {
  final Terminal terminal;
  final TerminalController controller;
  final FocusNode focusNode;

  TerminalPiece({
    Terminal? terminal,
    TerminalController? controller,
    FocusNode? focusNode,
  })  : controller = controller ?? TerminalController(),
        terminal = terminal ?? Constants.terminal(),
        focusNode = focusNode ?? FocusNode();
}
