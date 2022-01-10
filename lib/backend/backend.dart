import 'dart:io';
import 'dart:async';

import 'package:pty/pty.dart';
import 'package:xterm/xterm.dart';

class TerminalBackendX implements TerminalBackend {
  final StreamController<String> _outStream = StreamController<String>();

  TerminalBackendX(this.pty);

  PseudoTerminal pty;

  @override
  void ackProcessed() {
    // TODO: implement ackProcessed
  }

  @override
  Future<int> get exitCode => pty.exitCode;

  @override
  void init() {
    pty.out.listen((event) {
      _outStream.sink.add(event);
    });
  }

  @override
  Stream<String> get out => _outStream.stream;

  @override
  void resize(int width, int height, int pixelWidth, int pixelHeight) {
    pty.resize(width, height);
  }

  @override
  void terminate() {
    pty.kill(ProcessSignal.sigterm);
    _outStream.close();
  }

  @override
  void write(String input) {
    if (input.isEmpty) {
      return;
    }

    if (input == '\r') {
      //_outStream.sink.add('\r\n');
      pty.write('\r');
    } else if (input.codeUnitAt(0) == 127) {
      // Backspace handling
      //_outStream.sink.add('\b \b');
      pty.write('\b \b');
    } else {
      //_outStream.sink.add(input);
      pty.write(input);
    }
  }
}
