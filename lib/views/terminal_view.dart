import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:pty/pty.dart';
import 'package:terminal/constants/constants.dart';
import 'package:xterm/frontend/terminal_view.dart';
import 'package:xterm/xterm.dart';

class TheTerminalView extends StatefulWidget {
  const TheTerminalView({Key? key}) : super(key: key);

  @override
  State<TheTerminalView> createState() => _TheTerminalViewState();
}

PseudoTerminal get _pty => PseudoTerminal.start(
      r'zsh',
      ['-l'],
      environment: {'TERM': 'xterm-256color'},
    );

class _TheTerminalViewState extends State<TheTerminalView> {
  int index = 0;
  List<Terminal> tabs = [Constants.terminal(_pty)];
  List<FocusNode> focusNodes = [FocusNode()];

  @override
  void initState() {
    super.initState();

    focusNodes[index].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return TabView(
      shortcutsEnabled: true,
      currentIndex: index,
      onChanged: (newIndex) async {
        setState(() {
          index = newIndex;
        });
        await Future.delayed(const Duration(milliseconds: 300));
        focusNodes[newIndex].requestFocus();
      },
      onNewPressed: () async {
        setState(() {
          tabs.add(Constants.terminal(_pty));
          focusNodes.add(FocusNode());
          index = tabs.length - 1;
        });
        await Future.delayed(const Duration(milliseconds: 300));
        focusNodes[index].requestFocus();
      },
      tabs: List.generate(
        tabs.length,
        (mIndex) => Tab(
          text: Row(
            children: [
              Text("Terminal $mIndex"),
            ],
          ),
          icon: const Icon(Icons.computer),
          onClosed: () {
            setState(() {
              tabs.removeAt(mIndex);
              index = tabs.length - 1;
            });
          },
        ),
      ),
      bodies: tabs
          .map((Terminal terminal) => TerminalView(
                terminal: terminal,
                focusNode: focusNodes[index],
              ))
          .toList(),
    );
  }
}
