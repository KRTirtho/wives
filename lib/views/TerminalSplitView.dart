import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:wives/components/WindowTitleBar.dart';
import 'package:wives/models/constants.dart';
import 'package:wives/services/native.dart';
import 'package:xterm/flutter.dart';

class TerminalSplitView extends HookWidget {
  const TerminalSplitView({Key? key}) : super(key: key);

  Widget buildTerminal() {
    return TerminalView(
      terminal: Constants.terminal(Pty.start(
        NativeUtils.getShells().last,
        //['-l'],
        environment: {'TERM': 'xterm-256color'},
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    // for storing terminals with their preferred Axis
    final terminals = useState<List<Axis>>([Axis.horizontal]);

    final initAxis = useState<Axis>(Axis.horizontal);

    return Scaffold(
      appBar: WindowTitleBar(
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.horizontal_distribute),
              onPressed: () {
                if (terminals.value.length == 1) {
                  initAxis.value = Axis.horizontal;
                }
                terminals.value = [...terminals.value, Axis.horizontal];
              },
            ),
            IconButton(
              icon: const Icon(Icons.vertical_distribute),
              onPressed: () {
                if (terminals.value.length == 1) {
                  initAxis.value = Axis.vertical;
                }
                terminals.value = [...terminals.value, Axis.vertical];
              },
            ),
          ],
        ),
      ),
      body: MultiSplitView(
        axis: initAxis.value,
        children: [
          if (terminals.value.where((e) => e == Axis.horizontal).isNotEmpty &&
              initAxis.value == Axis.vertical)
            MultiSplitView(
              axis: Axis.horizontal,
              children: terminals.value
                  .where((e) => e == Axis.horizontal)
                  .map((_) => buildTerminal())
                  .toList(),
            ),
          if (terminals.value.where((e) => e == Axis.vertical).isNotEmpty &&
              initAxis.value == Axis.horizontal)
            MultiSplitView(
              axis: Axis.vertical,
              children: terminals.value
                  .where((e) => e == Axis.vertical)
                  .map((_) => buildTerminal())
                  .toList(),
            ),
          ...terminals.value
              .where((e) => e == initAxis.value)
              .map((_) => buildTerminal())
              .toList()
        ],
      ),
    );
  }
}
