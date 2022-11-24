import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:wives/intents/intents.dart';
import 'package:wives/services/native.dart';
import 'package:collection/collection.dart';

const digits = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
  LogicalKeyboardKey.digit7,
  LogicalKeyboardKey.digit8,
  LogicalKeyboardKey.digit9,
  LogicalKeyboardKey.digit0,
];

Map<SingleActivator, Intent> useTabShortcuts(
    WidgetRef ref, AutoScrollController scrollController) {
  final shells = NativeUtils.getShells().take(10);

  final Map<SingleActivator, Intent> entries = Map.fromEntries(
    shells.mapIndexed(
      (i, shell) {
        return MapEntry(
          SingleActivator(digits[i], alt: true, control: true),
          TabIntent(
            controller: scrollController,
            ref: ref,
            intentType: TabIntentType.create,
            shell: shell,
          ),
        );
      },
    ),
  );

  return useMemoized(
      () => {
            const SingleActivator(LogicalKeyboardKey.keyT, control: true):
                TabIntent(
              controller: scrollController,
              ref: ref,
              intentType: TabIntentType.create,
            ),
            const SingleActivator(LogicalKeyboardKey.keyW, control: true):
                TabIntent(
              controller: scrollController,
              ref: ref,
              intentType: TabIntentType.close,
            ),
            const SingleActivator(LogicalKeyboardKey.tab, control: true):
                TabIntent(
              controller: scrollController,
              ref: ref,
              intentType: TabIntentType.cycleForward,
            ),
            const SingleActivator(
              LogicalKeyboardKey.tab,
              control: true,
              shift: true,
            ): TabIntent(
              controller: scrollController,
              ref: ref,
              intentType: TabIntentType.cycleBackward,
            ),
            const SingleActivator(
              LogicalKeyboardKey.arrowDown,
              control: true,
              shift: true,
            ): SplitViewIntent(
              ref: ref,
              intentType: SplitViewIntentType.splitHorizontal,
            ),
            const SingleActivator(
              LogicalKeyboardKey.arrowRight,
              control: true,
              shift: true,
            ): SplitViewIntent(
              ref: ref,
              intentType: SplitViewIntentType.splitVertical,
            ),
            const SingleActivator(
              LogicalKeyboardKey.keyW,
              control: true,
              shift: true,
            ): SplitViewIntent(
              ref: ref,
              intentType: SplitViewIntentType.close,
            ),
            const SingleActivator(
              LogicalKeyboardKey.tab,
              control: true,
              alt: true,
            ): SplitViewIntent(
              ref: ref,
              intentType: SplitViewIntentType.focusNext,
            ),
            ...entries,
          },
      [ref, scrollController, entries]);
}
