import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:wives/components/CompactIconButton.dart';
import 'package:wives/hooks/useId.dart';
import 'package:wives/models/terminal_piece.dart';
import 'package:wives/providers/GrouperProvider.dart';
import 'package:wives/providers/PreferencesProvider.dart';
import 'package:xterm/ui.dart';
import 'package:tuple/tuple.dart';

class Grouper extends HookConsumerWidget {
  final TerminalPiece terminal;
  final VoidCallback? onClose;
  final String? parent;
  const Grouper({
    required this.terminal,
    this.onClose,
    this.parent,
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final nodeId = useId();
    final param = Tuple2(nodeId, parent);
    final grouperNode = ref.watch(grouperNodeProvider(param));
    final preferences = ref.watch(preferencesProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(grouperNodeSkeletonProvider).addNode(param);
      });
      return null;
    }, [param]);

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
                  onPressed: grouperNode.splitHorizontally,
                  child: const Icon(FluentIcons.split_horizontal_12_regular),
                ),
                const SizedBox(width: 4),
                CompactIconButton(
                  onPressed: grouperNode.splitVertically,
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
        terminal.terminal,
        padding: const EdgeInsets.all(5),
        autofocus: true,
        textStyle: TerminalStyle(
          fontSize: preferences.fontSize,
          fontFamily: "Cascadia Mono",
        ),
      ),
    );

    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
        dividerThickness: 2,
        dividerPainter: DividerPainter(
          backgroundColor: Colors.grey[700],
        ),
      ),
      child: MultiSplitView(
        axis: grouperNode.direction ?? Axis.horizontal,
        children: [
          if (grouperNode.innerGroup == null &&
              grouperNode.innerDirection == null)
            defaultBody
          else
            MultiSplitView(
              axis: grouperNode.innerDirection ?? Axis.horizontal,
              children: [
                defaultBody,
                ...?grouperNode.innerGroup?.map(
                  (e) => Grouper(
                    terminal: e,
                    parent: nodeId,
                    onClose: () {
                      grouperNode.removeInnerGroupTerminal(e);
                    },
                  ),
                ),
              ],
            ),
          ...?grouperNode.group?.map(
            (e) => Grouper(
                terminal: e,
                parent: nodeId,
                onClose: () {
                  grouperNode.removeGroupTerminal(e);
                }),
          ),
        ],
      ),
    );
  }
}
