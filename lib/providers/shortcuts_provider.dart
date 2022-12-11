import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/collection/terminal_actions.dart';
import 'package:wives/main.dart';
import 'package:wives/models/terminal_shortcut_activator.dart';

const kTerminalShortcuts = "terminal_shortcuts";

extension IconDataJson on IconData {
  static IconData fromJson(Map<String, dynamic> json) {
    return IconData(
      json['codePoint'],
      fontFamily: json['fontFamily'],
      fontPackage: json['fontPackage'],
      matchTextDirection: json['matchTextDirection'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "codePoint": codePoint,
      "fontFamily": fontFamily,
      "fontPackage": fontPackage,
      "matchTextDirection": matchTextDirection,
    };
  }
}

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
  final TerminalShortcutActivator? shortcut;
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

  factory TerminalAction.fromJson(
    Map<String, dynamic> json, {
    required Ref ref,
    required TerminalActionInvoker onInvoke,
  }) {
    return TerminalAction(
      ref: ref,
      onInvoke: onInvoke,
      title: json['title'],
      icon: json['icon'] != null ? IconDataJson.fromJson(json['icon']) : null,
      shortcut: TerminalShortcutActivator.fromJson(json['shortcut']),
      placement: Set.from(
        json['placement']?.map(
              (placementStr) {
                return TerminalActionPlacement.values
                    .firstWhere((placement) => placement.name == placementStr);
              },
            ) ??
            {TerminalActionPlacement.root},
      ),
      description: json['description'],
      closeAfterClick: json['closeAfterClick'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "icon": icon?.toJson(),
        "shortcut": shortcut?.toJson(),
        "placement": placement.map((e) => e.name).toList(),
      };

  TerminalAction copyWith({
    String? title,
    String? description,
    IconData? icon,
    TerminalShortcutActivator? shortcut,
    Set<TerminalActionPlacement>? placement,
    bool? closeAfterClick,
  }) {
    return TerminalAction(
      ref: ref,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      shortcut: shortcut ?? this.shortcut,
      placement: placement ?? this.placement,
      closeAfterClick: closeAfterClick ?? this.closeAfterClick,
      onInvoke: onInvoke,
    );
  }

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

  TerminalShortcuts(super.state, this.ref) {
    // CAUTION: It may create problem for the extension architecture

    localStorage.then((storage) async {
      final raw = storage.getString(kTerminalShortcuts);
      final List? localStates = raw != null ? jsonDecode(raw) : null;

      if (localStates == null) {
        return _updatePersistance();
      }

      final actions = localStates.map((localState) {
        final localAction = TerminalAction.fromJson(
          localState,
          ref: ref,
          onInvoke: (context, ref) {},
        );
        final stateOne = state.firstWhereOrNull(
          (element) => element.title == localAction.title,
        );
        if (stateOne != null) {
          state.remove(stateOne);
          return stateOne.copyWith(
            title: localAction.title,
            shortcut: localAction.shortcut,
            closeAfterClick: localAction.closeAfterClick,
            description: localAction.description,
            icon: localAction.icon,
            placement: localAction.placement,
          );
        }
        return localAction;
      }).toSet();

      state = {...state, ...actions};
    });
  }

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
    required TerminalShortcutActivator shortcut,
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

  void updateShortcut(
    String title,
    TerminalShortcutActivator shortcut,
  ) {
    final action = state.firstWhereOrNull((element) => element.title == title);
    if (action == null) {
      return;
    }
    state.remove(action);
    state = Set.from(
      [...state.toList(), action.copyWith(shortcut: shortcut)]
        ..sort((a, b) => a.title.compareTo(b.title)),
    );
  }

  void reset() {
    state = createDefaultActionsMap(ref).toSet();
  }

  @override
  set state(Set<TerminalAction> value) {
    super.state =
        value.toList().sorted((a, b) => a.title.compareTo(b.title)).toSet();
    _updatePersistance();
  }

  void _updatePersistance() async {
    final store = await localStorage;

    store.setString(
      kTerminalShortcuts,
      jsonEncode(
        state
            .where((element) => element.shortcut != null)
            .map((e) => e.toJson())
            .toList(),
      ),
    );
  }
}
