import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/riverpod.dart';
import 'package:wives/components/CommandPalette/palette_overlay.dart';
import 'package:wives/providers/preferences_provider.dart';
import 'package:wives/providers/shortcuts_provider.dart';
import 'package:wives/providers/terminal_tree.dart';
import 'package:wives/routes.dart';

/// These are all default actions and keybinding for terminal shortcuts.
/// It doesn't have to be added in order because it's always sorted by
/// title (A-Z).
///
/// These shortcuts will be used inside intents and also in the palette
///
/// CAUTION: Don't call ref.read(TerminalShortcuts.provider) inside any of these
/// CAUTION: shortcuts. It'll cause an infinite loop because the provider
/// CAUTION: will be called again and again.
///
/// INFO: If [icon] is null, the action will be treated as a keyboard-only
/// INFO: action and won't be shown in the palette.
///
/// INFO: If [shortcut] is null, the action will be treated as a palette-only
/// INFO: action and won't be shown in the keyboard shortcuts.

List<TerminalAction> createDefaultActionsMap(Ref ref) => [
      TerminalAction(
        ref: ref,
        title: "New Tab",
        description: "Create a new tab",
        icon: FluentIcons.add_12_regular,
        shortcut: LogicalKeySet(
          LogicalKeyboardKey.keyT,
          LogicalKeyboardKey.control,
        ),
        onInvoke: (context, ref) async {
          final terminal = ref.read(TerminalTree.provider);
          terminal.createNewTerminalTab();
        },
        placement: {
          TerminalActionPlacement.focusedTerminal,
          TerminalActionPlacement.root
        },
      ),
      TerminalAction(
        ref: ref,
        title: "Close Tab",
        description: "Close currently focused tab",
        icon: FluentIcons.calendar_cancel_16_regular,
        shortcut: LogicalKeySet(
          LogicalKeyboardKey.keyW,
          LogicalKeyboardKey.control,
        ),
        onInvoke: (context, ref) async {
          final terminal = ref.read(TerminalTree.provider);
          terminal.closeTerminalTab();
        },
        placement: {
          TerminalActionPlacement.focusedTerminal,
          TerminalActionPlacement.root
        },
      ),
      TerminalAction(
        ref: ref,
        title: "Cycle Forward Tab",
        shortcut: LogicalKeySet(
          LogicalKeyboardKey.tab,
          LogicalKeyboardKey.control,
        ),
        onInvoke: (context, ref) async {
          ref.read(TerminalTree.provider).cycleForwardTerminalTab();
        },
        placement: {
          TerminalActionPlacement.focusedTerminal,
          TerminalActionPlacement.root
        },
      ),
      TerminalAction(
        ref: ref,
        title: "Cycle Backward Tab",
        shortcut: LogicalKeySet(
          LogicalKeyboardKey.tab,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ),
        onInvoke: (context, ref) async {
          ref.read(TerminalTree.provider).cycleBackwardTerminalTab();
        },
        placement: {
          TerminalActionPlacement.focusedTerminal,
          TerminalActionPlacement.root
        },
      ),
      TerminalAction(
        ref: ref,
        title: "Split Vertically",
        description: "Vertically split currently focused terminal",
        icon: FluentIcons.split_vertical_12_regular,
        shortcut: LogicalKeySet(
          LogicalKeyboardKey.arrowRight,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ),
        onInvoke: (context, ref) async {
          final terminal = ref.read(TerminalTree.provider);
          terminal.focused?.split(TerminalAxis.column);
        },
        placement: {
          TerminalActionPlacement.focusedTerminal,
          TerminalActionPlacement.root
        },
      ),
      TerminalAction(
        ref: ref,
        title: "Split Horizontally",
        description: "Horizontally split currently focused terminal",
        icon: FluentIcons.split_horizontal_12_regular,
        shortcut: LogicalKeySet(
          LogicalKeyboardKey.arrowDown,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ),
        onInvoke: (context, ref) async {
          final terminal = ref.read(TerminalTree.provider);
          terminal.focused?.split(TerminalAxis.row);
        },
        placement: {
          TerminalActionPlacement.focusedTerminal,
          TerminalActionPlacement.root
        },
      ),
      TerminalAction(
        ref: ref,
        title: "Close Split Terminal",
        description: "Close focused terminal in the split view",
        icon: Icons.close,
        shortcut: LogicalKeySet(
          LogicalKeyboardKey.keyW,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ),
        onInvoke: (context, ref) async {
          final terminal = ref.read(TerminalTree.provider);
          final parent = terminal.focused?.parent;
          parent?.removeChild(terminal.focused!);
        },
        placement: {
          TerminalActionPlacement.focusedTerminal,
          TerminalActionPlacement.root
        },
      ),
      TerminalAction(
        ref: ref,
        title: "Settings",
        icon: FluentIcons.settings_28_regular,
        shortcut:
            LogicalKeySet(LogicalKeyboardKey.comma, LogicalKeyboardKey.control),
        onInvoke: (context, ref) async {
          final InheritedGoRouter? inherited =
              context.dependOnInheritedWidgetOfExactType<InheritedGoRouter>();
          (inherited?.goRouter ?? router).push("/settings");
        },
      ),
      TerminalAction(
        ref: ref,
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
      TerminalAction(
        ref: ref,
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
      TerminalAction(
        ref: ref,
        title: "Copy",
        icon: FluentIcons.copy_16_regular,
        shortcut: LogicalKeySet(
          LogicalKeyboardKey.keyC,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ),
        onInvoke: (context, ref) async {
          final terminal = ref.read(TerminalTree.provider);
          final node = terminal.focused ?? terminal.active;
          if (node == null) return;
          final text = node.terminal.buffer.getText(node.controller.selection);
          await Clipboard.setData(ClipboardData(text: text));
        },
        placement: {
          TerminalActionPlacement.focusedTerminal,
          TerminalActionPlacement.root
        },
      ),
      TerminalAction(
        ref: ref,
        title: "Paste",
        icon: FluentIcons.clipboard_paste_16_regular,
        shortcut: LogicalKeySet(
          LogicalKeyboardKey.keyV,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ),
        onInvoke: (context, ref) async {
          final terminal = ref.read(TerminalTree.provider);
          final node = terminal.focused ?? terminal.active;
          if (node == null) return;

          final data = await Clipboard.getData("text/plain");
          if (data?.text != null && data!.text!.isNotEmpty) {
            node.terminal.paste(data.text!);
          }
        },
        placement: {
          TerminalActionPlacement.focusedTerminal,
          TerminalActionPlacement.root
        },
      ),
      TerminalAction(
        ref: ref,
        title: "Open Palette",
        shortcut: LogicalKeySet(
          LogicalKeyboardKey.keyP,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ),
        placement: {
          TerminalActionPlacement.focusedTerminal,
          TerminalActionPlacement.root
        },
        onInvoke: (context, ref) async {
          final isOpen = ref.read(ActionStates.paletteState);
          final context = routerKey.currentState?.overlay?.context;
          if (isOpen) {
            return;
          }
          if (!isOpen && context != null) {
            showGeneralDialog(
              context: context,
              routeSettings: const RouteSettings(name: "palette"),
              pageBuilder: (context, animation1, animation2) {
                return const PaletteOverlay();
              },
              transitionDuration: const Duration(milliseconds: 70),
              barrierDismissible: true,
              barrierLabel: "",
              barrierColor: Colors.black26,
            ).then((value) {
              ref.read(ActionStates.paletteState.notifier).state = false;
            });
          }
        },
      ),
      TerminalAction(
        ref: ref,
        title: "Select text right",
        shortcut: LogicalKeySet(
          LogicalKeyboardKey.arrowRight,
          LogicalKeyboardKey.shift,
        ),
        onInvoke: (context, ref) {
          ref
              .read(TerminalTree.provider)
              .textSelection(CursorSelectorType.selectRight);
        },
        placement: {
          TerminalActionPlacement.focusedTerminal,
        },
      ),
      TerminalAction(
        ref: ref,
        title: "Select text left",
        shortcut: LogicalKeySet(
          LogicalKeyboardKey.arrowLeft,
          LogicalKeyboardKey.shift,
        ),
        onInvoke: (context, ref) {
          ref
              .read(TerminalTree.provider)
              .textSelection(CursorSelectorType.selectLeft);
        },
        placement: {
          TerminalActionPlacement.focusedTerminal,
        },
      ),
      TerminalAction(
        ref: ref,
        title: "Clear Selected text right",
        shortcut: LogicalKeySet(LogicalKeyboardKey.arrowRight),
        onInvoke: (context, ref) {
          ref
              .read(TerminalTree.provider)
              .textSelection(CursorSelectorType.clearRight);
        },
        placement: {
          TerminalActionPlacement.focusedTerminal,
        },
      ),
      TerminalAction(
        ref: ref,
        title: "Clear Selected text left",
        shortcut: LogicalKeySet(LogicalKeyboardKey.arrowLeft),
        onInvoke: (context, ref) {
          ref
              .read(TerminalTree.provider)
              .textSelection(CursorSelectorType.clearLeft);
        },
        placement: {
          TerminalActionPlacement.focusedTerminal,
        },
      ),
    ]..sort((a, b) => a.title.compareTo(b.title));

/// Private list of states for specific actions
class ActionStates {
  static final paletteState = StateProvider((ref) => false);
}
