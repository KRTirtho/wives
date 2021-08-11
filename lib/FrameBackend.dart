import 'dart:async';
import 'dart:io';

import 'package:pty/pty.dart';
import 'package:xterm/terminal/terminal_backend.dart';

class FrameBackend implements TerminalBackend {
  StreamController<String> _outStream = StreamController<String>();
  PseudoTerminal _pseudoTerminal = PseudoTerminal.start(
    r'bash',
    ['-l'],
    environment: {'TERM': 'xterm-256color'},
  );

  @override
  void ackProcessed() {
    // TODO: Wait for pty to catch up.
  }

  @override
  Future<int> get exitCode => _pseudoTerminal.exitCode;

  @override
  void init() {
    _pseudoTerminal.out.listen((event) {
      _outStream.sink.add(event);
    });
  }

  @override
  Stream<String> get out => _outStream.stream;

  @override
  void resize(int width, int height, int pixelWidth, int pixelHeight) {
    _pseudoTerminal.resize(width, height);
  }

  @override
  void terminate() {
    _pseudoTerminal.kill(ProcessSignal.sigkill);
    _outStream.close();
  }

  @override
  void write(String input) {
    if (input.length <= 0) {
      return;
    }

    if (input == '\r') {
      //_outStream.sink.add('\r\n');
      _pseudoTerminal.write('\r');
    } else if (input.codeUnitAt(0) == 127) {
      // Backspace handling
      //_outStream.sink.add('\b \b');
      _pseudoTerminal.write('\b \b');
    } else {
      //_outStream.sink.add(input);
      _pseudoTerminal.write(input);
    }
  }
}
