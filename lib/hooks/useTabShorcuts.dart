import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:wives/models/intents.dart';

Map<SingleActivator, Intent> useTabShortcuts(
    WidgetRef ref, AutoScrollController scrollController) {
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
          },
      [ref, scrollController]);
}
