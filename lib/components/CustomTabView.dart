import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wives/components/WindowTitleBar.dart';

class CycleForwardTabsIntent extends Intent {}

class CycleBackwardsTabsIntent extends Intent {}

class NewTabIntent extends Intent {}

class CloseCurrentTabIntent extends Intent {}

class CustomTabView extends HookWidget {
  final List<Widget> tabs;
  final List<Widget> children;

  final int Function(int index)? onClose;
  final int Function()? onNewTab;

  const CustomTabView({
    required this.tabs,
    required this.children,
    this.onClose,
    this.onNewTab,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeIndex = useState(0);
    final scrollController = useScrollController();

    useEffect(() {
      if (tabs.length != children.length) {
        throw Exception(
            "Length of tabs & children should be equal but found ${tabs.length} tabs but ${children.length} children");
      }
      return null;
    }, [tabs, children]);

    final createNewTab = useCallback(() {
      final index = onNewTab?.call();

      if (index != null) activeIndex.value = index;
    }, [activeIndex.value]);

    final closeTab = useCallback((int i) {
      if (children.length <= 1) return;
      // closes the Tab/Removes the tab
      final index = onClose?.call(i);
      if (index != null) {
        activeIndex.value = index;
      }
    }, [activeIndex.value]);

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.tab):
            CycleForwardTabsIntent(),
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.tab,
        ): CycleBackwardsTabsIntent(),
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyT,
        ): NewTabIntent(),
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyW,
        ): CloseCurrentTabIntent(),
      },
      child: Actions(
        actions: {
          CycleForwardTabsIntent: CallbackAction<CycleForwardTabsIntent>(
            onInvoke: (_) {
              if (tabs.length - 1 == activeIndex.value) {
                activeIndex.value = 0;
              } else {
                activeIndex.value = activeIndex.value + 1;
              }
              return null;
            },
          ),
          CycleBackwardsTabsIntent: CallbackAction<CycleBackwardsTabsIntent>(
            onInvoke: (_) {
              if (activeIndex.value == 0) {
                activeIndex.value = tabs.length - 1;
              } else {
                activeIndex.value = activeIndex.value - 1;
              }
              return null;
            },
          ),
          NewTabIntent:
              CallbackAction<NewTabIntent>(onInvoke: (_) => createNewTab()),
          CloseCurrentTabIntent: CallbackAction<CloseCurrentTabIntent>(
              onInvoke: (_) => closeTab(activeIndex.value)),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: WindowTitleBar(
              nonDraggableLeading: Center(
                child: IconButton(
                  hoverColor: Colors.grey.withOpacity(0.2),
                  icon: const Icon(Icons.add_rounded),
                  onPressed: createNewTab,
                ),
              ),
              leading: Scrollbar(
                controller: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: tabs
                        .mapIndexed(
                          (i, tab) => InkWell(
                            onTap: activeIndex.value != i
                                ? () {
                                    activeIndex.value = i;
                                  }
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: activeIndex.value == i
                                    ? Colors.grey[800]
                                    : null,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Material(
                                type: MaterialType.transparency,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(children: [
                                    tab,
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded),
                                      iconSize: 15,
                                      onPressed: () => closeTab(i),
                                    )
                                  ]),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            body: children[activeIndex.value],
          ),
        ),
      ),
    );
  }
}
