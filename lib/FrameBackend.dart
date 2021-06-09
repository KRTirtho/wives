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
    _outStream.sink.add("Starting pseudo terminal...");
    _pseudoTerminal = PseudoTerminal.start(
      r'cmd',
      ['-l'],
      environment: {'TERM': 'xterm-256color'},
    );
    _pseudoTerminal.out.listen((event) {
      _outStream.sink.add(event);
    });
    _outStream.sink.add("Started pseudo terminal...");
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
  }

}