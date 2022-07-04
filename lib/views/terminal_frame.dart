import 'package:flutter/services.dart';
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
      onRequestFocus: (index) {
        final tab = tabEntries.elementAt(index).key;
        tab.requestFocus();
      },
      onUnfocus: (index) {
        final tab = tabEntries.elementAt(index).key;
        tab.unfocus();
      },
      onCopy: (index) async {
        final tab = tabEntries.elementAt(index).value;

        if ((tab.selectedText ?? "").isEmpty == true) return;
        await Clipboard.setData(ClipboardData(text: tab.selectedText));
      },
      onPaste: (index) async {
        final tab = tabEntries.elementAt(index).value;

        final data = await Clipboard.getData("text/plain");
        if (data?.text != null && data!.text!.isNotEmpty) {
          tab.write(data.text!);
        }
      },
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
        final prevEntry = tabEntries[i].value;
        prevEntry.terminateBackend();
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
        // internal xterm.dart library was modified to add support for
        // scrolling thus need to create PR in TerminalStudio/xterm.dart
        return TerminalView(
          padding: 5,
          autofocus: true,
          terminal: tab.value,
          focusNode: tab.key,
        );
      }).toList(),
    );
  }
}
