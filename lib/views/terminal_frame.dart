import 'dart:io';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:terminal/components/CustomTabView.dart';
import 'package:terminal/models/constants.dart';
import 'package:xterm/frontend/terminal_view.dart';
import 'package:xterm/xterm.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

Pty get _pty => Pty.start(
      shell,
      //['-l'],
      environment: {'TERM': 'xterm-256color'},
    );

String get shell {
  if (Platform.isWindows) {
    return 'cmd.exe';
  } else {
    if (File("/usr/bin/zsh").existsSync()) {
      return 'zsh';
    }
    if (File("/usr/bin/bash").existsSync()) {
      return 'bash';
    }
    return "sh";
  }
}

class TerminalFrame extends HookWidget {
  const TerminalFrame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabs = useState<Map<FocusNode, Terminal>>({
      FocusNode(): Constants.terminal(_pty),
    });

    useEffect(() {
      // requesting focus to the latest terminal
      tabs.value.entries.last.key.requestFocus();
      return null;
    }, [tabs.value]);

    final tabEntries =
        useMemoized(() => tabs.value.entries.toList(), [tabs.value]);

    return Scaffold(
      body: CustomTabView(
        tabs: tabs.value.entries
            .mapIndexed((i, _) => Text("Terminal $i"))
            .toList(),
        onNewTab: () {
          tabs.value = {
            ...tabs.value,
            FocusNode(): Constants.terminal(_pty),
          };
          return tabs.value.length - 1;
        },
        onClose: (i) {
          tabs.value = Map.fromEntries(
            tabEntries.where(
              (entry) =>
                  entry.key != tabEntries[i].key &&
                  entry.value != tabEntries[i].value,
            ),
          );
          return tabs.value.length - 1;
        },
        children: tabEntries.map((tab) {
          return Expanded(
            child: TerminalView(
              padding: 5,
              terminal: tab.value,
              autofocus: true,
              focusNode: tab.key,
            ),
          );
        }).toList(),
      ),
    );
  }
}
