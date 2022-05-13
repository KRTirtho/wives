import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';

class TerminalBackendX implements TerminalBackend {
  final StreamController<String> _outStream = StreamController<String>();

  TerminalBackendX(this.pty);

  Pty pty;

  @override
  void ackProcessed() {
    // TODO: implement ackProcessed
  }

  @override
  Future<int> get exitCode => pty.exitCode;

  @override
  void init() {
    pty.output.cast<List<int>>().transform(const Utf8Decoder()).listen((text) {
      _outStream.sink.add(text);
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
      pty.write(const Utf8Encoder().convert('\r'));
    } else if (input.codeUnitAt(0) == 127) {
      // Backspace handling
      //_outStream.sink.add('\b \b');
      pty.write(const Utf8Encoder().convert('\b \b'));
    } else {
      //_outStream.sink.add(input);
      pty.write(const Utf8Encoder().convert(input));
    }
  }
}
