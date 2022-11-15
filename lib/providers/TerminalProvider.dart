import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tuple/tuple.dart';
import 'package:wives/models/constants.dart';
import 'package:wives/providers/PreferencesProvider.dart';
import 'package:xterm/xterm.dart';

/// This class or provider holds all the information for all the terminals
class Terminals extends ChangeNotifier {
  Map<FocusNode, Tuple2<Terminal, TerminalController>> instances;
  int activeIndex;
  final Ref ref;

  PreferencesProvider get preferences => ref.read(preferencesProvider);

  Terminals(this.ref)
      : instances = {
          FocusNode(): Tuple2(Constants.terminal(), TerminalController())
        },
        activeIndex = 0,
        super();

  void addInstance(
      Terminal terminal, TerminalController controller, FocusNode focusNode) {
    instances[focusNode] = Tuple2(terminal, controller);
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
    addInstance(
      Constants.terminal(shell ?? preferences.defaultShell),
      TerminalController(),
      focusNode,
    );

    final index = instances.length - 1;
    setActiveIndex(index);
    focusNode.requestFocus();
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

  void closeTerminalTabByInstance(Terminal terminal) {
    final node = instances.keys.firstWhereOrNull(
      (key) => instances[key] == terminal,
    );
    if (instances.length <= 1 || node == null) return;
    // closes the Tab/Removes the tab by instance
    removeInstance(node);
    setActiveIndex(instances.length - 1);
    terminalAt(activeIndex)?.key.requestFocus();
  }

  MapEntry<FocusNode, Tuple2<Terminal, TerminalController>>? terminalAt(
      int index) {
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
}

final terminalProvider = ChangeNotifierProvider((ref) {
  return Terminals(ref);
});
