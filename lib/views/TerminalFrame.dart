import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:terminal/FrameBackend.dart';
import 'package:xterm/flutter.dart';
import 'package:xterm/xterm.dart';

class TerminalFrame extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TerminalFrameState();
  }
}

class TerminalFrameState extends State<TerminalFrame> {

  late Terminal _terminal;

  @override
  void initState() {
    super.initState();
    _terminal = Terminal(
        maxLines: 10000,
        backend: FrameBackend(),
    );
    //_terminal.debug.enable();
    _terminal.setBlinkingCursor(true);
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

            ],
          )),
        )),
      body: SafeArea(
        child: Scrollbar(
          child: TerminalView(
            terminal: _terminal,
          ),
        ),
      ),
    );
  }

}