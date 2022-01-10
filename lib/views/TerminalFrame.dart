import 'dart:io';

import 'package:flutter/material.dart';
import 'package:terminal/FrameBackend.dart';
import 'package:xterm/flutter.dart';
import 'package:xterm/xterm.dart';

class TerminalFrame extends StatefulWidget {
  const TerminalFrame({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TerminalFrameState();
  }
}

class TerminalFrameState extends State<TerminalFrame> {
  late Terminal _terminal;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _terminal = Terminal(
      maxLines: 10000,
      backend: FrameBackend(),
    );
    //_terminal.debug.enable();
    _terminal.setBlinkingCursor(true);
    _terminal.backend?.exitCode.then((value) => {exit(value)});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: PreferredSize(
      //  preferredSize: Size.fromHeight(55.0),
      //  child: AppBar(
      //    elevation: 0.0,
      //    bottom: PreferredSize(
      //      preferredSize: Size.fromHeight(55.0),
      //      child: Row(
      //        children: [],
      //      )),
      //  )),
      body: SafeArea(
        child: Scrollbar(
          child: TerminalView(
            terminal: _terminal,
            scrollController: _controller,
          ),
          controller: _controller,
        ),
      ),
    );
  }
}
