import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:wives/components/CompactIconButton.dart';
import 'package:wives/components/WindowTitleBar.dart';
import 'package:wives/hooks/useAutoScrollController.dart';
import 'package:wives/hooks/usePaletteOverlay.dart';
import 'package:wives/services/native.dart';

class CustomTabView extends HookWidget {
  final List<Widget> tabs;
  final List<Widget> children;

  final void Function(int index) onCopy;
  final void Function(int index) onPaste;
  final void Function(int index) onRequestFocus;
  final void Function(int index) onUnfocus;

  final int Function(int index)? onClose;
  final int Function(String shell)? onNewTab;

  const CustomTabView({
    required this.tabs,
    required this.children,
    required this.onCopy,
    required this.onPaste,
    required this.onRequestFocus,
    required this.onUnfocus,
    this.onClose,
    this.onNewTab,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeIndex = useState(0);
    final scrollController = useAutoScrollController();

    useEffect(() {
      if (tabs.length != children.length) {
        throw Exception(
            "Length of tabs & children should be equal but found ${tabs.length} tabs but ${children.length} children");
      }
      return null;
    }, [tabs, children]);

    final createNewTab = useCallback((String shell) {
      final index = onNewTab?.call(shell);

      if (index != null) {
        activeIndex.value = index;
        scrollController.scrollToIndex(
          index,
          preferPosition: AutoScrollPosition.begin,
        );
      }
    }, [activeIndex.value]);

    final closeTab = useCallback((int i) {
      if (children.length <= 1) return;
      // closes the Tab/Removes the tab
      final index = onClose?.call(i);
      if (index != null) {
        activeIndex.value = index;
      }
    }, [activeIndex.value]);

    final shells = useMemoized(() => NativeUtils.getShells(), []);

    final openPalette = usePaletteOverlay();

    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyC,
        ): () => onCopy(activeIndex.value),
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyV,
        ): () => onPaste(activeIndex.value),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.tab): () {
          if (tabs.length - 1 == activeIndex.value) {
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
            activeIndex.value = tabs.length - 1;
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
        ): () => createNewTab(shells.last),
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
                itemCount: tabs.length + 1,
                itemBuilder: (context, i) {
                  if (tabs.length == i) {
                    return Center(
                      child: Row(
                        children: [
                          const SizedBox(width: 5),
                          CompactIconButton(
                            onPressed: () => createNewTab(shells.last),
                            child: const Icon(Icons.add_rounded),
                          ),
                          PopupMenuButton<String>(
                            position: PopupMenuPosition.under,
                            onSelected: (value) {
                              createNewTab(value);
                            },
                            onCanceled: () {
                              onRequestFocus(activeIndex.value);
                            },
                            offset: const Offset(0, 10),
                            tooltip: "Shells",
                            itemBuilder: (context) {
                              return shells
                                  .map((shell) => PopupMenuItem(
                                        value: shell,
                                        child: Text(shell),
                                      ))
                                  .toList();
                            },
                            child:
                                const Icon(Icons.keyboard_arrow_down_rounded),
                          ),
                        ],
                      ),
                    );
                  }

                  final tab = tabs[i];
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
                                tab,
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
          body: children[activeIndex.value],
        ),
      ),
    );
  }
}
