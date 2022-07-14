import 'package:flutter/widgets.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/models/constants.dart';
import 'package:wives/services/native.dart';
import 'package:xterm/terminal/terminal_ui_interaction.dart';
import 'package:xterm/xterm.dart';

/// This class or provider holds all the information for all the terminals
class TerminalProvider extends ChangeNotifier {
  Map<FocusNode, Terminal> terminals;

  TerminalProvider()
      : terminals = {
          FocusNode(): Constants.terminal(Pty.start(
            NativeUtils.getShells().last,
            //['-l'],
            environment: {'TERM': 'xterm-256color'},
          ))
        },
        super();

  void addTerminal(Terminal terminal, FocusNode focusNode) {
    terminals[focusNode] = terminal;
    notifyListeners();
  }

  void removeTerminal(FocusNode focusNode) {
    terminals.remove(focusNode);
    notifyListeners();
  }
}

final terminalProvider = ChangeNotifierProvider((ref) {
  return TerminalProvider();
});
