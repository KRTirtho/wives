import 'dart:async';
import 'dart:io';

import 'package:pty/pty.dart';
import 'package:xterm/terminal/terminal_backend.dart';

class FrameBackend implements TerminalBackend {

  StreamController<String> _outStream = StreamController<String>();
  late PseudoTerminal _pseudoTerminal;

  @override
  void ackProcessed() {
    // TODO: implement ackProcessed
  }

  @override
  Future<int> get exitCode => _pseudoTerminal.exitCode;

  @override
  void init() {
    _pseudoTerminal = PseudoTerminal.start(
      r'cmd',
      ['-l'],
      environment: {'TERM': 'xterm-256color'},
    );
    _pseudoTerminal.out.listen((event) {
      _outStream.sink.add(event);
    });
  }

  @override
  Stream<String> get out => _outStream.stream;

  @override
  void resize(int width, int height) {
    _pseudoTerminal.resize(width, height);
  }

  @override
  void terminate() {
    _pseudoTerminal.kill(ProcessSignal.sigkill);
  }

  @override
  void write(String input) {
    _pseudoTerminal.write(input);


    if (input.length <= 0) {
      return;
    }

    if (input == '\r') {
      _outStream.sink.add('\r\n');
      _outStream.sink.add('\$ ');
    } else if (input.codeUnitAt(0) == 127) {
      // Backspace handling
      _outStream.sink.add('\b \b');
    } else {
      _outStream.sink.add(input);
    }
  }

}