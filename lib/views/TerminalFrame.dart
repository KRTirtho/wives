import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pty/pty.dart';
import 'package:xterm/flutter.dart';
import 'package:xterm/frontend/input_behavior_desktop.dart';
import 'package:xterm/mouse/mouse_mode.dart';
import 'package:xterm/xterm.dart';

class TerminalFrame extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TerminalFrameState();
  }

}

class TerminalFrameState extends State<TerminalFrame> {

  late Terminal _terminal;
  PseudoTerminal _pty = PseudoTerminal.start('cmd', ['-1'], environment: {'TERM': 'xterm-256color'},);

  @override
  void initState() {
    _terminal = Terminal(
        onInput: _pty.write,
        platform: PlatformBehaviors.windows
    );
    _terminal.setBlinkingCursor(true);
    _pty.out.listen(_terminal.write);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: AppBar(
          elevation: 0.0,
          bottom: PreferredSize(
            preferredSize:
            Size.fromHeight(55.0),
            child: Row(
            children: [
              MaterialButton(onPressed: () {
                _pty.write("echo hi");
              }, child: Text("PRESS ME"),)
            ],
          )),
        )),
      body: CupertinoScrollbar(
        child: TerminalView(
          terminal: _terminal,
          onResize: _pty.resize,
        ),
      ),
    );
  }

}