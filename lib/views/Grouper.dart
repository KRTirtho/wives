import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:wives/components/CompactIconButton.dart';
import 'package:wives/providers/PreferencesProvider.dart';
import 'package:wives/providers/TerminalTree.dart';
import 'package:xterm/core.dart';
import 'package:xterm/ui.dart';

class Grouper extends HookConsumerWidget {
  final TerminalNode node;
  final VoidCallback? onClose;
  final void Function(TapDownDetails details, CellOffset offset)?
      onSecondaryTapDown;
  final Map<ShortcutActivator, Intent>? shortcuts;
  const Grouper({
    required this.node,
    this.onClose,
    this.onSecondaryTapDown,
    this.shortcuts,
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final preferences = ref.watch(preferencesProvider);

    useEffect(() {
      listener() {
        if (node.focusNode.hasFocus) {
          // grouperNode.setActive(node);
        }
      }

      node.focusNode.addListener(listener);
      return () {
        node.focusNode.removeListener(listener);
      };
    }, [node.focusNode]);

    final defaultBody = Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(30),
        child: Material(
          color: Colors.grey[850],
          child: IconTheme(
            data: const IconThemeData(size: 18, color: Colors.white),
            child: Row(
              children: [
                const SizedBox(width: 4),
                CompactIconButton(
                  onPressed: () {
                    node.split(TerminalAxis.row);
                  },
                  child: const Icon(FluentIcons.split_horizontal_12_regular),
                ),
                const SizedBox(width: 4),
                CompactIconButton(
                  onPressed: () {
                    node.split(TerminalAxis.column);
                  },
                  child: const Icon(FluentIcons.split_vertical_12_regular),
                ),
                const Spacer(),
                if (onClose != null)
                  CompactIconButton(
                    onPressed: onClose,
                    child: const Icon(Icons.close_sharp),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: TerminalView(
        node.terminal,
        padding: const EdgeInsets.all(5),
        autofocus: true,
        focusNode: node.focusNode,
        controller: node.controller,
        textStyle: TerminalStyle(
          fontSize: preferences.fontSize,
          fontFamily: "Cascadia Mono",
        ),
        onSecondaryTapDown: onSecondaryTapDown,
        shortcuts: shortcuts,
      ),
    );

    final invertedAxis =
        node.axis == TerminalAxis.row ? TerminalAxis.column : TerminalAxis.row;

    if (node.isLeaf) return defaultBody;

    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
        dividerThickness: 2,
        dividerPainter: DividerPainter(
          backgroundColor: Colors.grey[700],
        ),
      ),
      child: MultiSplitView(
        axis: node.axis,
        children: [
          MultiSplitView(
            axis: invertedAxis,
            children: [
              defaultBody,
              ...node.disobedientChildren!.map(
                (childNode) => Grouper(
                  node: childNode,
                  onSecondaryTapDown: onSecondaryTapDown,
                  shortcuts: shortcuts,
                  onClose: () {
                    node.removeChild(childNode);
                  },
                ),
              ),
            ],
          ),
          ...?node.obedientChildren?.map(
            (childNode) {
              return Grouper(
                node: childNode,
                onSecondaryTapDown: onSecondaryTapDown,
                shortcuts: shortcuts,
                onClose: () {
                  node.removeChild(childNode);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
