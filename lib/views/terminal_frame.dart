import 'dart:io';

import 'package:flutter_pty/flutter_pty.dart';
import 'package:terminal/constants/constants.dart';
import 'package:xterm/frontend/terminal_view.dart';
import 'package:xterm/xterm.dart';
import 'package:zenit_ui/zenit_ui.dart';

class TerminalFrame extends StatefulWidget {
  const TerminalFrame({Key? key}) : super(key: key);

  @override
  State<TerminalFrame> createState() => _TerminalFrameState();
}

Pty get _pty => Pty.start(
      shell,
      //['-l'],
      environment: {'TERM': 'xterm-256color'},
    );

String get shell {
  if (Platform.isWindows) {
    return r'cmd.exe';
  } else {
    if (File("/usr/bin/zsh").existsSync()) {
      return r'zsh';
    }
    if (File("/usr/bin/bash").existsSync()) {
      return r'bash';
    }
    return "sh";
  }
}

class _TerminalFrameState extends State<TerminalFrame> {
  final Map<FocusNode, Terminal> tabs = {
    FocusNode(): Constants.terminal(_pty),
  };
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    tabs.entries.first.key.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: TabView(
        pages: tabs
            .map((FocusNode focusNode, Terminal terminal) => MapEntry(
                focusNode,
                TabViewPage(
                  title: "Terminal",
                  view: TerminalView(
                    terminal: terminal,
                    focusNode: focusNode,
                  ),
                )))
            .values
            .toList(),
        onNewPage: () => setState(() {
          tabs.addEntries([MapEntry(FocusNode(), Constants.terminal(_pty))]);
        }),
        onPageClosed: (index) {
          tabs.removeWhere((key, value) =>
              tabs.entries.elementAt(index).key == key &&
              tabs.entries.elementAt(index).value == value);
          tabs.entries.elementAt(tabs.length - 1).key.requestFocus();
        },
        onPageChanged: (index) {
          tabs.entries.elementAt(index).key.requestFocus();
        },
      ),
    );
  }
}
