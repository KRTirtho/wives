import 'package:flutter/widgets.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/models/constants.dart';
import 'package:wives/providers/PreferencesProvider.dart';
import 'package:wives/services/native.dart';
import 'package:xterm/xterm.dart';

/// This class or provider holds all the information for all the terminals
class Terminals extends ChangeNotifier {
  Map<FocusNode, Terminal> instances;
  int activeIndex;
  final Ref ref;

  PreferencesProvider get preferences => ref.read(preferencesProvider);

  Terminals(this.ref)
      : instances = {
          FocusNode(): Constants.terminal(Pty.start(
            NativeUtils.getShells().last,
            //['-l'],
            environment: {'TERM': 'xterm-256color'},
          ))
        },
        activeIndex = 0,
        super();

  void addInstance(Terminal terminal, FocusNode focusNode) {
    instances[focusNode] = terminal;
    notifyListeners();
  }

  void removeInstance(FocusNode focusNode) {
    instances.remove(focusNode);
    notifyListeners();
  }

  void setActiveIndex(int index) {
    activeIndex = index;
    notifyListeners();
  }

  int createTerminalTab([String? shell]) {
    final shells = NativeUtils.getShells();
    final focusNode = FocusNode();
    addInstance(
      Constants.terminal(
        Pty.start(
          shell ?? preferences.defaultShell ?? shells.last,
          environment: {'TERM': 'xterm-256color'},
        ),
      ),
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

  MapEntry<FocusNode, Terminal>? terminalAt(int index) {
    return instances.entries.toList()[index];
  }

  int cycleForwardTerminalTab() {
    if (instances.length - 1 == activeIndex) {
      setActiveIndex(0);
    } else {
      setActiveIndex(activeIndex + 1);
    }
    terminalAt(activeIndex)?.key.requestFocus();
    return activeIndex;
  }

  int cycleBackwardTerminalTab() {
    if (activeIndex == 0) {
      setActiveIndex(instances.length - 1);
    } else {
      setActiveIndex(activeIndex - 1);
    }
    terminalAt(activeIndex)?.key.requestFocus();
    return activeIndex;
  }
}

final terminalProvider = ChangeNotifierProvider((ref) {
  return Terminals(ref);
});
