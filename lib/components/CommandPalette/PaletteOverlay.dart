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
import 'package:wives/providers/PreferencesProvider.dart';
import 'package:wives/providers/TerminalTree.dart';

final Set<PaletteAction> actionsMap = {
  PaletteAction(
    title: "New Tab",
    description: "Create a new tab",
    icon: FluentIcons.add_12_regular,
    shortcut:
        LogicalKeySet(LogicalKeyboardKey.keyT, LogicalKeyboardKey.control),
    onInvoke: (context, ref) async {
      final terminal = ref.read(TerminalTree.provider);
      terminal.createNewTerminalTab();
    },
  ),
  PaletteAction(
    title: "Settings",
    icon: FluentIcons.settings_28_regular,
    shortcut:
        LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
    onInvoke: (context, ref) async {
      GoRouter.of(context).push("/settings");
    },
  ),
  PaletteAction(
    title: "Increase Font Size",
    icon: FluentIcons.font_increase_20_regular,
    shortcut:
        LogicalKeySet(LogicalKeyboardKey.equal, LogicalKeyboardKey.control),
    closeAfterClick: false,
    onInvoke: (context, ref) async {
      ref.read(preferencesProvider).setFontSize(
            ref.read(preferencesProvider).fontSize + 1,
          );
    },
  ),
  PaletteAction(
    title: "Decrease Font Size",
    icon: FluentIcons.font_decrease_20_regular,
    closeAfterClick: false,
    shortcut:
        LogicalKeySet(LogicalKeyboardKey.minus, LogicalKeyboardKey.control),
    onInvoke: (context, ref) async {
      ref.read(preferencesProvider).setFontSize(
            ref.read(preferencesProvider).fontSize - 1,
          );
    },
  ),
  PaletteAction(
    title: "Copy",
    icon: FluentIcons.copy_16_regular,
    shortcut: LogicalKeySet(
      LogicalKeyboardKey.keyC,
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
    ),
    onInvoke: (context, ref) async {
      final terminal = ref.read(TerminalTree.provider);
      final node = terminal.active;
      if (node == null) return;
      Actions.of(context).invokeAction(
        CopyPasteAction(),
        CopyPasteIntent(
          node.terminal,
          controller: node.controller,
          intentType: CopyPasteIntentType.copy,
        ),
      );
    },
  ),
  PaletteAction(
    title: "Paste",
    icon: FluentIcons.clipboard_paste_16_regular,
    shortcut: LogicalKeySet(
      LogicalKeyboardKey.keyV,
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
    ),
    onInvoke: (context, ref) async {
      final terminal = ref.read(TerminalTree.provider);
      final node = terminal.active;
      if (node == null) return;
      Actions.of(context).invokeAction(
        CopyPasteAction(),
        CopyPasteIntent(
          node.terminal,
          controller: node.controller,
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

    final focusNode = useFocusNode();

    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.escape): () {
          Navigator.of(context).pop();
        },
        LogicalKeySet(LogicalKeyboardKey.arrowDown): () {
          focusNode.nextFocus();
        },
        LogicalKeySet(LogicalKeyboardKey.arrowUp): () {
          focusNode.previousFocus();
        },
      },
      child: Dialog(
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
                    focusNode: focusNode,
                    maxLines: 1,
                    onChanged: (value) => text.value = value,
                    textInputAction: TextInputAction.next,
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
                                      ...action.shortcut!.keys.map(
                                        (key) => KeyboardKeyWidget(
                                          keyboardKey: key.keyLabel,
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
      ),
    );
  }
}
