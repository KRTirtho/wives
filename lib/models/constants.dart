import 'dart:convert';

import 'package:flutter_pty/flutter_pty.dart';
import 'package:wives/services/native.dart';
import 'package:xterm/xterm.dart';

class Constants {
  static Terminal terminal([String? shell]) {
    final terminal = Terminal();
    final pty = Pty.start(
      shell ?? NativeUtils.getShells().last,
      columns: terminal.viewWidth,
      rows: terminal.viewHeight,
      environment: {'TERM': 'xterm-256color'},
    );

    pty.output
        .cast<List<int>>()
        .transform(const Utf8Decoder())
        .listen(terminal.write);

    pty.exitCode.then((code) {
      terminal.write('the process exited with exit code $code');
    });

    terminal.onOutput = (data) {
      pty.write(const Utf8Encoder().convert(data));
    };

    terminal.onResize = (w, h, pw, ph) {
      pty.resize(h, w);
    };

    return terminal;
  }
}
