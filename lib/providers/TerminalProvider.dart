import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/models/constants.dart';
import 'package:wives/models/terminal_group.dart';
import 'package:wives/models/terminal_piece.dart';
import 'package:wives/providers/PreferencesProvider.dart';
import 'package:xterm/xterm.dart';

/// This class or provider holds all the information for all the terminals
class Terminals extends ChangeNotifier {
  Map<FocusNode, TerminalGroup> instances;
  int activeIndex;
  final Ref ref;

  PreferencesProvider get preferences => ref.read(preferencesProvider);

  Terminals(this.ref)
      : instances = {
          FocusNode(): TerminalGroup(horizontalTerminals: [TerminalPiece()])
        },
        activeIndex = 0,
        super();

  void addGroupInstance(TerminalGroup terminalGroup, FocusNode focusNode) {
    instances[focusNode] = terminalGroup;
    notifyListeners();
  }

  void setGroupTerminals(
    TerminalGroup group, {
    List<TerminalPiece>? horizontalTerminals,
    List<TerminalPiece>? verticalTerminals,
  }) {
    final originalGroup = instances.entries
        .firstWhereOrNull(
          (element) => element.value == group,
        )
        ?.key;
    if (originalGroup == null) return;

    if (horizontalTerminals != null) {
      instances[originalGroup]?.horizontalTerminals = horizontalTerminals;
    }

    if (verticalTerminals != null) {
      instances[originalGroup]?.verticalTerminals = verticalTerminals;
    }
    notifyListeners();
  }

  void removeInstance(FocusNode focusNode) {
    instances.remove(focusNode);
    focusNode.dispose();
    notifyListeners();
  }

  void setActiveIndex(int index) {
    activeIndex = index;
    notifyListeners();
  }

  int createTerminalTab([String? shell]) {
    final focusNode = FocusNode();
    final terminalFocusNode = FocusNode();
    addGroupInstance(
      TerminalGroup(
        horizontalTerminals: [
          TerminalPiece(
            terminal: Constants.terminal(shell),
            controller: TerminalController(),
            focusNode: terminalFocusNode,
          ),
        ],
      ),
      focusNode,
    );

    final index = instances.length - 1;
    setActiveIndex(index);
    focusNode.requestFocus();
    terminalFocusNode.requestFocus();
    return index;
  }

  void closeTerminalTab([int? index]) {
    if (instances.length <= 1) return;
    // closes the Tab/Removes the tab
    removeInstance(
      terminalAt(index ?? activeIndex)!.key,
    );
    setActiveIndex(instances.length - 1);
    terminalAt(activeIndex)?.key.requestFocus();
  }

  void closeTerminalTabByInstance(TerminalGroup terminalGroup) {
    final node = instances.keys.firstWhereOrNull(
      (key) => instances[key] == terminalGroup,
    );
    if (instances.length <= 1 || node == null) return;
    // closes the Tab/Removes the tab by instance
    removeInstance(node);
    setActiveIndex(instances.length - 1);
    terminalAt(activeIndex)?.key.requestFocus();
  }

  MapEntry<FocusNode, TerminalGroup>? terminalAt(int index) {
    return instances.entries.toList()[index];
  }

  int cycleForwardTerminalTab() {
    int index = instances.length - 1 == activeIndex ? 0 : activeIndex + 1;
    setActiveIndex(index);
    terminalAt(index)?.key.requestFocus();
    return index;
  }

  int cycleBackwardTerminalTab() {
    int index = activeIndex == 0 ? instances.length - 1 : activeIndex - 1;
    setActiveIndex(index);
    terminalAt(index)?.key.requestFocus();
    return index;
  }

  TerminalGroup? get activeGroup => terminalAt(activeIndex)?.value;
}

final terminalProvider = ChangeNotifierProvider((ref) {
  return Terminals(ref);
});
