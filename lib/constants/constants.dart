import 'package:flutter_pty/flutter_pty.dart';
import 'package:terminal/backend/backend.dart';
import 'package:xterm/xterm.dart';

class Constants {
  static Terminal terminal(Pty pty) => Terminal(
        maxLines: 10000,
        backend: TerminalBackendX(pty),
      );
}
