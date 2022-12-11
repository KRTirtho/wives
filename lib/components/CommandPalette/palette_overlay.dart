import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tuple/tuple.dart';
import 'package:wives/collection/terminal_actions.dart';
import 'package:wives/components/keyboard_key.dart';
import 'package:wives/providers/shortcuts_provider.dart';

const _specialLKeys = [
  LogicalKeyboardKey.tab,
  LogicalKeyboardKey.arrowUp,
  LogicalKeyboardKey.arrowDown,
  LogicalKeyboardKey.arrowLeft,
  LogicalKeyboardKey.arrowRight,
  LogicalKeyboardKey.enter,
  LogicalKeyboardKey.delete,
  LogicalKeyboardKey.home,
  LogicalKeyboardKey.end,
  LogicalKeyboardKey.pageDown,
  LogicalKeyboardKey.pageUp,
  LogicalKeyboardKey.numLock,
  LogicalKeyboardKey.meta,
  LogicalKeyboardKey.superKey,
  LogicalKeyboardKey.capsLock,
  LogicalKeyboardKey.superKey,
];

class PaletteOverlay extends HookConsumerWidget {
  const PaletteOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final text = useState("");
    final actionsMap = ref.watch(
      TerminalShortcuts.provider.notifier.select((s) => s.paletteActions),
    );

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(ActionStates.paletteState.notifier).state = true;
      });
      return null;
    }, []);

    final filteredActions = useMemoized(
      () => text.value.isEmpty
          ? actionsMap
          : actionsMap
              .map((e) => Tuple2(weightedRatio(e.title, text.value), e))
              .toList()
              .sorted((a, b) => b.item1.compareTo(a.item1))
              .map((e) => e.item2)
              .toList(),
      [text.value],
    );

    final focusNode = useFocusNode();

    final controller = useScrollController();

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () {
          focusNode.nextFocus();
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
                color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]?.withOpacity(.3)
                    : Colors.grey[300]?.withOpacity(.6)),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(10),
              child: KeyboardListener(
                focusNode: useFocusNode(),
                onKeyEvent: (value) {
                  if (value is KeyUpEvent) return;
                  if (_specialLKeys.contains(value.logicalKey)) return;
                  focusNode.requestFocus();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      autofocus: true,
                      focusNode: focusNode,
                      maxLines: 1,
                      onChanged: (value) => text.value = value,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: "Search any available commands",
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Material(
                        type: MaterialType.transparency,
                        child: ListView.builder(
                          itemCount: filteredActions.length,
                          controller: controller,
                          itemBuilder: (context, index) {
                            final action = filteredActions.elementAt(index);
                            return HookBuilder(builder: (context) {
                              final listTileFocusNode = useFocusNode();

                              useEffect(() {
                                listener() {
                                  if (listTileFocusNode.hasFocus) {
                                    controller.animateTo(
                                      index * 30.0,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                }

                                listTileFocusNode.addListener(listener);
                                return () {
                                  listTileFocusNode.removeListener(listener);
                                };
                              }, [listTileFocusNode]);

                              return ListTile(
                                focusNode: listTileFocusNode,
                                leading: Icon(action.icon),
                                title: Text(action.title),
                                dense: true,
                                horizontalTitleGap: 0,
                                subtitle: action.description != null
                                    ? Text(
                                        action.description!,
                                        style:
                                            Theme.of(context).textTheme.caption,
                                      )
                                    : null,
                                trailing: action.shortcut != null
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ...action.shortcut!.withModifierKeys
                                              .map(
                                            (key) => KeyboardKeyWidget(
                                              keyboardKey: key.keyLabel,
                                            ),
                                          )
                                        ],
                                      )
                                    : null,
                                onTap: () async {
                                  await action.invoke(context);
                                  if (action.closeAfterClick) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              );
                            });
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
      ),
    );
  }
}
