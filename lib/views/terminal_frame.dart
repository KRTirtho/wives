import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_pty/flutter_pty.dart';
import 'package:terminal/constants/constants.dart';
import 'package:terminal/views/terminal_settings.dart';
import 'package:xterm/frontend/terminal_view.dart';
import 'package:xterm/xterm.dart';

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
    return m.Material(
      color: Colors.transparent,
      child: m.Theme(
        data: m.ThemeData(
          brightness: m.Brightness.dark,
        ),
        child: TabView(
          wheelScroll: true,
          scrollController: ScrollPosController(),
          tabWidthBehavior: TabWidthBehavior.equal,
          showScrollButtons: true,
          shortcutsEnabled: true,
          currentIndex: index,
          footer: m.IconButton(
            onPressed: () {
              m.Navigator.of(context).push(
                m.MaterialPageRoute(
                  builder: (context) => const TerminalSettings(),
                ),
              );
            },
            icon: const m.Icon(m.Icons.settings_outlined),
            padding: EdgeInsets.zero,
          ),
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
                  Text("Terminal ${mIndex + 1}"),
                ],
              ),
              icon: const Icon(m.Icons.computer),
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
        ),
      ),
    );
  }
}
