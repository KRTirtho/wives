import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:wives/components/CustomTabView.dart';
import 'package:wives/models/constants.dart';
import 'package:wives/services/native.dart';
import 'package:xterm/frontend/terminal_view.dart';
import 'package:xterm/xterm.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class TerminalFrame extends HookWidget {
  const TerminalFrame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shells = NativeUtils.getShells();
    final tabs = useState<Map<FocusNode, Terminal>>({
      FocusNode(): Constants.terminal(Pty.start(
        shells.last,
        //['-l'],
        environment: {'TERM': 'xterm-256color'},
      )),
    });

    useEffect(() {
      // requesting focus to the latest terminal
      tabs.value.entries.last.key.requestFocus();
      return null;
    }, [tabs.value]);

    final tabEntries =
        useMemoized(() => tabs.value.entries.toList(), [tabs.value]);

    return CustomTabView(
      tabs:
          tabs.value.entries.mapIndexed((i, _) => Text("Terminal $i")).toList(),
      onNewTab: (shell) {
        tabs.value = {
          ...tabs.value,
          FocusNode(): Constants.terminal(
            Pty.start(
              shell,
              //['-l'],
              environment: {'TERM': 'xterm-256color'},
            ),
          ),
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
        return TerminalView(
          padding: 5,
          terminal: tab.value,
          autofocus: true,
          focusNode: tab.key,
        );
      }).toList(),
    );
  }
}
