import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/collection/terminal_actions.dart';

class TerminalIntent extends Intent {
  final TerminalAction action;
  final BuildContext context;
  const TerminalIntent(this.context, this.action);
}

class TerminalIntentAction extends Action<TerminalIntent> {
  @override
  Object? invoke(covariant TerminalIntent intent) {
    return intent.action.invoke(intent.context);
  }
}

typedef TerminalActionInvoker = FutureOr<void> Function(
  BuildContext context,
  Ref ref,
);

enum TerminalActionPlacement {
  root,
  focusedTerminal,
}

class TerminalAction {
  final String title;
  final String? description;
  final IconData? icon;
  final bool closeAfterClick;
  final LogicalKeySet? shortcut;
  final Ref ref;
  final Set<TerminalActionPlacement> placement;

  @protected
  final TerminalActionInvoker onInvoke;

  TerminalAction({
    required this.ref,
    required this.title,
    this.icon,
    required this.onInvoke,
    this.shortcut,
    this.placement = const {TerminalActionPlacement.root},
    this.description,
    this.closeAfterClick = true,
  })  : assert(
          placement.isNotEmpty,
          "TerminalAction must have at least one placement",
        ),
        assert(
          shortcut != null || icon != null,
          "TerminalAction must have either a shortcut or an icon",
        );

  FutureOr<void> invoke(BuildContext context) => onInvoke(context, ref);

  @override
  operator ==(Object other) =>
      other is TerminalAction &&
      other.title == title &&
      other.shortcut == shortcut &&
      other.description == description &&
      other.icon == icon &&
      other.onInvoke == onInvoke;

  @override
  int get hashCode => Object.hash(title, shortcut, description, icon, onInvoke);
}

class TerminalShortcuts extends StateNotifier<Set<TerminalAction>> {
  static final provider =
      StateNotifierProvider<TerminalShortcuts, Set<TerminalAction>>(
    (ref) => TerminalShortcuts(
      createDefaultActionsMap(ref).toSet(),
      ref,
    ),
  );

  final Ref ref;

  TerminalShortcuts(super.state, this.ref);

  Set<TerminalAction> get rootActions => state
      .where(
        (element) =>
            element.placement.contains(TerminalActionPlacement.root) &&
            element.shortcut != null,
      )
      .toSet();

  Set<TerminalAction> get focusedTerminalActions => state
      .where(
        (element) =>
            element.placement
                .contains(TerminalActionPlacement.focusedTerminal) &&
            element.shortcut != null,
      )
      .toSet();

  Set<TerminalAction> get paletteActions => state
      .where(
        (element) => element.icon != null,
      )
      .toSet();

  TerminalAction addShortcut({
    required String title,
    required IconData icon,
    required bool closeAfterClick,
    required Ref ref,
    required TerminalActionInvoker onInvoke,
    required LogicalKeySet shortcut,
    String? description,
  }) {
    final action = TerminalAction(
      ref: ref,
      title: title,
      description: description,
      icon: icon,
      onInvoke: onInvoke,
      shortcut: shortcut,
      closeAfterClick: closeAfterClick,
    );
    state = {...state, action};
    return action;
  }
}
