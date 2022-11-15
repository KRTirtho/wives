import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/components/KeyboardKey.dart';
import 'package:wives/models/intents.dart';
import 'package:wives/models/palette_actions.dart';
import 'package:wives/providers/TerminalProvider.dart';

final Set<PaletteAction> actionsMap = {
  PaletteAction(
    title: "New Tab",
    description: "Create a new tab",
    icon: FluentIcons.add_12_regular,
    shortcut: const SingleActivator(LogicalKeyboardKey.keyT, control: true),
    onInvoke: (context, ref) async {
      final terminal = ref.read(terminalProvider);
      final index = terminal.createTerminalTab();
      terminal.terminalAt(index)?.key.requestFocus();
    },
  ),
  PaletteAction(
    title: "Settings",
    icon: FluentIcons.settings_28_regular,
    shortcut: const SingleActivator(LogicalKeyboardKey.keyS, control: true),
    onInvoke: (context, ref) async {
      GoRouter.of(context).push("/settings");
    },
  ),
  PaletteAction(
    title: "Copy",
    icon: FluentIcons.copy_16_regular,
    shortcut: const SingleActivator(LogicalKeyboardKey.keyC,
        control: true, shift: true),
    onInvoke: (context, ref) async {
      final terminal = ref.read(terminalProvider);
      final instance = terminal.terminalAt(terminal.activeIndex);
      if (instance == null) return;
      Actions.of(context).invokeAction(
        CopyPasteAction(),
        CopyPasteIntent(
          instance.value.item1,
          controller: instance.value.item2,
          intentType: CopyPasteIntentType.copy,
        ),
      );
    },
  ),
  PaletteAction(
    title: "Paste",
    icon: FluentIcons.clipboard_paste_16_regular,
    shortcut: const SingleActivator(LogicalKeyboardKey.keyV,
        control: true, shift: true),
    onInvoke: (context, ref) async {
      final terminal = ref.read(terminalProvider);
      final instance = terminal.terminalAt(terminal.activeIndex);
      if (instance == null) return;
      Actions.of(context).invokeAction(
        CopyPasteAction(),
        CopyPasteIntent(
          instance.value.item1,
          controller: instance.value.item2,
          intentType: CopyPasteIntentType.paste,
        ),
      );
    },
  ),
};

class PaletteOverlay extends HookConsumerWidget {
  const PaletteOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final text = useState("");

    final filteredActions = useMemoized(
      () => text.value.isEmpty
          ? actionsMap
          : actionsMap
              .where(
                (action) => action.title
                    .toLowerCase()
                    .contains(text.value.toLowerCase()),
              )
              .toList(),
      [text.value],
    );

    return Dialog(
      alignment: Alignment.topCenter,
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * .7,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[800]?.withOpacity(.3),
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  autofocus: true,
                  maxLines: 1,
                  onChanged: (value) => text.value = value,
                  decoration: InputDecoration(
                    hintText: "Search any available commands",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey[800]!,
                        width: 2,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListView.builder(
                      itemCount: filteredActions.length,
                      itemBuilder: (context, index) {
                        final action = filteredActions.elementAt(index);
                        return ListTile(
                          leading: Icon(action.icon),
                          title: Text(action.title),
                          dense: true,
                          horizontalTitleGap: 0,
                          subtitle: action.description != null
                              ? Text(
                                  action.description!,
                                  style: Theme.of(context).textTheme.caption,
                                )
                              : null,
                          trailing: action.shortcut != null
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...action.shortcut!
                                        .debugDescribeKeys()
                                        .replaceAll("Key ", "")
                                        .replaceAll("+ ", "")
                                        .split(" ")
                                        .map(
                                          (key) => KeyboardKeyWidget(
                                            keyboardKey: key,
                                          ),
                                        )
                                  ],
                                )
                              : null,
                          onTap: () async {
                            await action.onInvoke(context, ref);
                            if (action.closeAfterClick) {
                              Navigator.of(context).pop();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
