import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/components/compact_icon_button.dart';
import 'package:wives/components/keyboard_key.dart';
import 'package:wives/components/window_title_bar.dart';
import 'package:wives/models/terminal_shortcut_activator.dart';
import 'package:wives/providers/shortcuts_provider.dart';

class KeyboardShortcutEditor extends HookConsumerWidget {
  const KeyboardShortcutEditor({Key? key}) : super(key: key);

  List<LogicalKeyboardKey> get modifiers => [
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.shift,
        LogicalKeyboardKey.alt,
        LogicalKeyboardKey.meta,
      ];

  LogicalKeyboardKey normalizeDiShortcuts(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight) {
      return LogicalKeyboardKey.control;
    }
    if (key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight) {
      return LogicalKeyboardKey.shift;
    }
    if (key == LogicalKeyboardKey.altLeft ||
        key == LogicalKeyboardKey.altRight) {
      return LogicalKeyboardKey.alt;
    }
    if (key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight) {
      return LogicalKeyboardKey.meta;
    }
    return key;
  }

  bool hasModifierKey(Set<LogicalKeyboardKey> keys) {
    return keys.contains(LogicalKeyboardKey.control) ||
        keys.contains(LogicalKeyboardKey.meta) ||
        keys.contains(LogicalKeyboardKey.shift) ||
        keys.contains(LogicalKeyboardKey.alt);
  }

  @override
  Widget build(BuildContext context, ref) {
    final shortcuts = ref.watch(TerminalShortcuts.provider.select((s) => s
        .where(
          (s) => s.shortcut == null
              ? true
              : hasModifierKey(s.shortcut!.withModifierKeys.toSet()),
        )
        .toList()));

    final controller = useScrollController();

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: WindowTitleBar(
        nonDraggableLeading: const BackButton(),
        leading: Center(
          child: Text(
            "Edit Keyboard Shortcuts",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        center: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Tooltip(
              message: "Reset to default",
              child: CompactIconButton(
                onPressed: () =>
                    ref.read(TerminalShortcuts.provider.notifier).reset(),
                child: const Icon(Icons.restart_alt_rounded),
              ),
            ),
          ),
        ),
      ),
      body: Scrollbar(
        controller: controller,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(scrollbars: false),
              child: ListView.separated(
                controller: controller,
                itemCount: shortcuts.length,
                shrinkWrap: true,
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 5,
                    indent: 10,
                    endIndent: 10,
                  );
                },
                itemBuilder: (context, index) {
                  final shortcut = shortcuts.elementAt(index);
                  return ListTile(
                    title: Text(shortcut.title),
                    subtitle: shortcut.description != null
                        ? Text(shortcut.description!)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...?shortcut.shortcut?.withModifierKeys.map(
                          (key) => KeyboardKeyWidget(
                            keyboardKey: key.keyLabel,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CompactIconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              useRootNavigator: false,
                              builder: (context) {
                                return HookBuilder(builder: (context) {
                                  final keys =
                                      useState<Set<LogicalKeyboardKey>>({});
                                  final focusNode = useFocusNode();
                                  final save = useCallback(
                                    () {
                                      ref
                                          .read(TerminalShortcuts
                                              .provider.notifier)
                                          .updateShortcut(
                                            shortcut.title,
                                            TerminalShortcutActivator
                                                .deterministic(keys.value),
                                          );
                                      Navigator.of(context).pop();
                                    },
                                    [shortcut, keys.value],
                                  );

                                  final isSameShortcut =
                                      shortcut.shortcut?.withModifierKeys.every(
                                                (element) =>
                                                    keys.value.contains(
                                                  normalizeDiShortcuts(element),
                                                ),
                                              ) ==
                                              true &&
                                          keys.value.length ==
                                              shortcut.shortcut
                                                  ?.withModifierKeys.length;

                                  return AlertDialog(
                                    contentPadding: const EdgeInsets.all(15),
                                    titlePadding: const EdgeInsets.all(15),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(shortcut.title),
                                            if (shortcut.description != null)
                                              Text(
                                                shortcut.description!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption,
                                              ),
                                          ],
                                        ),
                                        CompactIconButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Icon(Icons.close_sharp),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: keys.value.isNotEmpty &&
                                                hasModifierKey(keys.value) &&
                                                !isSameShortcut
                                            ? save
                                            : null,
                                        child: const Text("Save"),
                                      ),
                                    ],
                                    content: KeyboardListener(
                                      autofocus: true,
                                      focusNode: focusNode,
                                      onKeyEvent: (value) {
                                        if (value is KeyUpEvent) return;
                                        if (value.logicalKey ==
                                            LogicalKeyboardKey.escape) {
                                          return;
                                        }
                                        if (value.logicalKey ==
                                            LogicalKeyboardKey.enter) {
                                          return save();
                                        }
                                        final notModifiers = keys.value.where(
                                          (element) {
                                            return !modifiers.contains(element);
                                          },
                                        );
                                        if (notModifiers.length == 1 &&
                                            !modifiers
                                                .contains(normalizeDiShortcuts(
                                              value.logicalKey,
                                            ))) return;
                                        keys.value = {
                                          ...keys.value,
                                          normalizeDiShortcuts(
                                            value.logicalKey,
                                          ),
                                        };
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 16),
                                          if (isSameShortcut)
                                            Text(
                                              "Cannot assign same key combination",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption!,
                                            ),
                                          if (keys.value.isNotEmpty &&
                                              !hasModifierKey(keys.value))
                                            Text(
                                              "No modifier key (ctrl, alt, meta) is assigned",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption,
                                            ),
                                          const SizedBox(height: 16),
                                          if (keys.value.isEmpty)
                                            Text(
                                              "Press a key to set the shortcut",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    ?.color,
                                              ),
                                            )
                                          else
                                            Wrap(
                                              children: [
                                                ...keys.value.map(
                                                  (key) => KeyboardKeyWidget(
                                                    keyboardKey: key.keyLabel,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                              },
                            );
                          },
                          child: const Icon(FluentIcons.edit_16_regular),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
