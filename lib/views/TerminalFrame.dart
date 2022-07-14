import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:wives/components/CompactIconButton.dart';
import 'package:wives/components/WindowTitleBar.dart';
import 'package:wives/hooks/useAutoScrollController.dart';
import 'package:wives/hooks/usePaletteOverlay.dart';
import 'package:wives/hooks/useSearchOverlay.dart';
import 'package:wives/models/constants.dart';
import 'package:wives/providers/PreferencesProvider.dart';
import 'package:wives/providers/TerminalProvider.dart';
import 'package:wives/services/native.dart';
import 'package:xterm/frontend/terminal_view.dart';
import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

class TerminalFrame extends HookConsumerWidget {
  const TerminalFrame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final shells = NativeUtils.getShells();
    final terminalStore = ref.watch(terminalProvider);
    final preferences = ref.watch(preferencesProvider);

    final activeIndex = useState(0);
    final scrollController = useAutoScrollController();

    final createNewTab = useCallback((String shell) {
      terminalStore.addTerminal(
        Constants.terminal(
          Pty.start(
            shell,
            environment: {'TERM': 'xterm-256color'},
          ),
        ),
        FocusNode(),
      );

      final index = terminalStore.terminals.length - 1;

      activeIndex.value = index;
      scrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.begin,
      );
    }, [activeIndex.value, preferences.defaultWorkingDirectory]);

    final closeTab = useCallback((int i) {
      if (terminalStore.terminals.length <= 1) return;
      // closes the Tab/Removes the tab
      terminalStore
          .removeTerminal(terminalStore.terminals.entries.elementAt(i).key);
      final index = terminalStore.terminals.length - 1;
      activeIndex.value = index;
    }, [activeIndex.value]);

    final openPalette = usePaletteOverlay();

    final currentTerminal =
        terminalStore.terminals.entries.elementAt(activeIndex.value).value;

    final isSearchOpen = useState(false);

    useEffect(() {
      if (isSearchOpen.value) {
        isSearchOpen.value = false;
      }
      currentTerminal.isUserSearchActive = false;
      return null;
    }, [activeIndex.value]);

    useSearchOverlay(
      isSearchOpen.value,
      onClose: () {
        isSearchOpen.value = false;
        currentTerminal.isUserSearchActive = false;
      },
      onSearch: (value) {
        currentTerminal.userSearchPattern = value;
      },
      onUpdateSearchOptions: (options) {
        currentTerminal.userSearchOptions = options;
      },
    );

    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyF,
        ): () {
          isSearchOpen.value = !isSearchOpen.value;
          currentTerminal.isUserSearchActive = isSearchOpen.value;
        },
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyC,
        ): () async {
          final tab = terminalStore.terminals.entries
              .elementAt(activeIndex.value)
              .value;

          if ((tab.selectedText ?? "").isEmpty == true) return;
          await Clipboard.setData(ClipboardData(text: tab.selectedText));
        },
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyV,
        ): () async {
          final tab = terminalStore.terminals.entries
              .elementAt(activeIndex.value)
              .value;

          final data = await Clipboard.getData("text/plain");
          if (data?.text != null && data!.text!.isNotEmpty) {
            tab.write(data.text!);
          }
        },
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.tab): () {
          if (terminalStore.terminals.length - 1 == activeIndex.value) {
            activeIndex.value = 0;
          } else {
            activeIndex.value = activeIndex.value + 1;
          }
          scrollController.scrollToIndex(
            activeIndex.value,
            preferPosition: AutoScrollPosition.end,
          );
        },
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.tab,
        ): () {
          if (activeIndex.value == 0) {
            activeIndex.value = terminalStore.terminals.length - 1;
          } else {
            activeIndex.value = activeIndex.value - 1;
          }
          scrollController.scrollToIndex(
            activeIndex.value,
            preferPosition: AutoScrollPosition.end,
          );
        },
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyT,
        ): () => createNewTab(preferences.defaultShell ?? shells.last),
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyW,
        ): () => closeTab(activeIndex.value),
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyP,
        ): () {
          openPalette();
        },
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.comma):
            () {
          Navigator.of(context).pushNamed("/settings");
        },

        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.equal):
            () {
          preferences.setFontSize(preferences.fontSize + 1);
        },
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.minus):
            () {
          preferences.setFontSize(preferences.fontSize - 1);
        },

        // this mitigates the Arrow Up focus change issue
        LogicalKeySet(LogicalKeyboardKey.arrowUp): () {},
        // this mitigates the Tab focus change issue
        LogicalKeySet(LogicalKeyboardKey.tab): () {},
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: WindowTitleBar(
            leading: Scrollbar(
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: terminalStore.terminals.length + 1,
                itemBuilder: (context, i) {
                  if (terminalStore.terminals.length == i) {
                    return Center(
                      child: Row(
                        children: [
                          const SizedBox(width: 5),
                          CompactIconButton(
                            onPressed: () => createNewTab(
                              preferences.defaultShell ?? shells.last,
                            ),
                            child: const Icon(Icons.add_rounded),
                          ),
                          PopupMenuButton<String>(
                            position: PopupMenuPosition.under,
                            onSelected: (value) {
                              if (value == "settings") {
                                Navigator.of(context).pushNamed("/settings");
                              } else {
                                createNewTab(value);
                              }
                            },
                            onCanceled: () {
                              final tab = terminalStore.terminals.entries
                                  .elementAt(activeIndex.value)
                                  .key;
                              tab.requestFocus();
                            },
                            offset: const Offset(0, 10),
                            tooltip: "Shells",
                            color: Colors.black,
                            itemBuilder: (context) {
                              return [
                                ...shells
                                    .map((shell) => PopupMenuItem(
                                          height: 30,
                                          value: shell,
                                          child: ListTile(
                                            dense: true,
                                            horizontalTitleGap: 0,
                                            contentPadding: EdgeInsets.zero,
                                            leading: const Icon(
                                                Icons.terminal_rounded),
                                            title: Text(shell),
                                          ),
                                        ))
                                    .toList(),
                                const PopupMenuItem(
                                  height: 30,
                                  value: "settings",
                                  child: ListTile(
                                    dense: true,
                                    horizontalTitleGap: 0,
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(Icons.settings_outlined),
                                    title: Text("Settings"),
                                  ),
                                )
                              ];
                            },
                            child:
                                const Icon(Icons.keyboard_arrow_down_rounded),
                          ),
                        ],
                      ),
                    );
                  }

                  final tab = "Terminal $i";
                  return AutoScrollTag(
                    controller: scrollController,
                    index: i,
                    key: ValueKey(i),
                    child: InkWell(
                      onTap: activeIndex.value != i
                          ? () {
                              activeIndex.value = i;
                              scrollController.scrollToIndex(
                                i,
                                preferPosition: AutoScrollPosition.end,
                              );
                            }
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color:
                              activeIndex.value == i ? Colors.grey[800] : null,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Material(
                          type: MaterialType.transparency,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(children: [
                                Text(tab),
                                const SizedBox(width: 5),
                                CompactIconButton(
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 15,
                                  ),
                                  onPressed: () => closeTab(i),
                                )
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          body: terminalStore.terminals.entries.map((tab) {
            // internal xterm.dart library was modified to add support for
            // scrolling thus need to create PR in TerminalStudio/xterm.dart
            return TerminalView(
              padding: 5,
              autofocus: true,
              terminal: tab.value,
              focusNode: tab.key,
              style: TerminalStyle(fontSize: preferences.fontSize),
            );
          }).toList()[activeIndex.value],
        ),
      ),
    );
  }
}
