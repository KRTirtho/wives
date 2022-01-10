import 'package:pty/pty.dart';
import 'package:terminal/backend/backend.dart';
import 'package:xterm/xterm.dart';

class Constants {
  static Terminal terminal(PseudoTerminal pty) => Terminal(
        maxLines: 10000,
        backend: TerminalBackendX(pty),
      );
}
