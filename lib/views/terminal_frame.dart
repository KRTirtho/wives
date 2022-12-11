import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:wives/components/compact_icon_button.dart';
import 'package:wives/components/window_title_bar.dart';
import 'package:wives/hooks/useUpdateChecker.dart';
import 'package:wives/main.dart';
import 'package:wives/extensions/color.dart';
import 'package:wives/providers/preferences_provider.dart';
import 'package:wives/providers/shortcuts_provider.dart';
import 'package:wives/providers/terminal_tree.dart';
import 'package:wives/services/native.dart';
import 'package:flutter/material.dart';
import 'package:wives/components/terminal_split_group.dart';

class TerminalFrame extends HookConsumerWidget {
  const TerminalFrame({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final scrollController = ref.watch(tabScrollControllerProvider);
    final shells = NativeUtils.getShells();
    final terminalTree = ref.watch(TerminalTree.provider);

    final activeRoot = terminalTree.active;
    final activeRootIndex = terminalTree.activeIndex;

    void closeTab(int index) {
      terminalTree.closeTerminalTab(terminalTree.nodes[index]);
    }

    final shortcuts = ref.watch(
      TerminalShortcuts.provider.notifier.select(
        (s) => s.focusedTerminalActions.map(
          (t) => MapEntry(t.shortcut!, TerminalIntent(context, t)),
        ),
      ),
    );

    useUpdateChecker(ref);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        /// This is an exception for creating terminal tab with default shell
        /// Because this tab gets created before [PreferencesProvider] is initialized
        terminalTree.createNewTerminalTab(
          (await localStorage).getString('defaultShell'),
          (await localStorage).getString('defaultWorkingDirectory'),
        );
      });
      return null;
    }, []);

    final calculatedWidth = 160 * (terminalTree.nodes.length + 1);
    final viewPortWidth = MediaQuery.of(context).size.width;

    final appBar = WindowTitleBar(
      nonDraggableLeading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: (calculatedWidth > viewPortWidth
                    ? viewPortWidth
                    : calculatedWidth) -
                150,
            child: Scrollbar(
              controller: scrollController,
              child: ReorderableListView.builder(
                onReorder: terminalTree.reorderTerminalTabs,
                scrollDirection: Axis.horizontal,
                scrollController: scrollController,
                shrinkWrap: true,
                itemCount: terminalTree.nodes.length,
                buildDefaultDragHandles: false,
                proxyDecorator: (child, index, animation) {
                  return Material(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: Tween<double>(begin: 0, end: 2).transform(
                            animation.value,
                          ),
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                itemBuilder: (context, i) {
                  return AutoScrollTag(
                    controller: scrollController,
                    index: i,
                    key: ValueKey(terminalTree.nodes[i]),
                    child: TabbarTab(
                      index: i,
                      onClose: () => closeTab(i),
                      node: terminalTree.nodes[i],
                      scrollController: scrollController,
                    ),
                  );
                },
              ),
            ),
          ),
          Center(
            child: Row(
              children: [
                const SizedBox(width: 5),
                CompactIconButton(
                  onPressed: terminalTree.createNewTerminalTab,
                  child: const Icon(Icons.add_rounded),
                ),
                PopupMenuButton<String>(
                  position: PopupMenuPosition.under,
                  onSelected: (value) {
                    if (value == "settings") {
                      GoRouter.of(context).push("/settings");
                    } else {
                      terminalTree.createNewTerminalTab(value);
                    }
                  },
                  onCanceled: activeRoot?.focusNode.requestFocus,
                  offset: const Offset(0, 10),
                  tooltip: "Shells",
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
                                  leading: const Icon(Icons.terminal_rounded),
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
                  child: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              ],
            ),
          )
        ],
      ),
    );
    return Scaffold(
      appBar: appBar,
      body: terminalTree.nodes.isNotEmpty && activeRootIndex != null
          ? terminalTree.nodes.map((tab) {
              final isActive = activeRoot == tab;
              return TerminalSplitGroup(
                node: tab,
                onSecondaryTapDown: (activeNode, info, cell) async {
                  final value = await showMenu<String>(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      info.globalPosition.dx,
                      info.globalPosition.dy,
                      info.globalPosition.distance + info.globalPosition.dx,
                      info.globalPosition.distance + info.globalPosition.dy,
                    ),
                    items: [
                      const PopupMenuItem(
                        value: "Copy",
                        height: 30,
                        child: ListTile(
                          dense: true,
                          horizontalTitleGap: 0,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(FluentIcons.copy_16_regular),
                          title: Text("Copy"),
                        ),
                      ),
                      const PopupMenuItem(
                        value: "Paste",
                        height: 30,
                        child: ListTile(
                          dense: true,
                          horizontalTitleGap: 0,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(FluentIcons.clipboard_paste_16_regular),
                          title: Text("Paste"),
                        ),
                      ),
                      const PopupMenuItem(
                        value: "Open Settings",
                        height: 30,
                        child: ListTile(
                          dense: true,
                          horizontalTitleGap: 0,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(FluentIcons.settings_16_regular),
                          title: Text("Settings"),
                        ),
                      ),
                    ],
                  );
                  if (value == null) return;
                  final action = ref
                      .read(TerminalShortcuts.provider)
                      .firstWhere((element) => element.title == value);

                  await action.invoke(context);
                },
                shortcuts: Map.fromEntries(shortcuts),
              );
            }).toList()[activeRootIndex]
          : Container(),
    );
  }
}

class TabbarTab extends HookConsumerWidget {
  final int index;
  final TerminalNode node;
  final AutoScrollController scrollController;
  final VoidCallback onClose;
  const TabbarTab({
    Key? key,
    required this.index,
    required this.onClose,
    required this.node,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final terminalTree = ref.watch(TerminalTree.provider);
    final activeRoot = terminalTree.active;
    final title = ref.watch(preferencesProvider.select(
          (value) => value.defaultWorkingDirectory,
        )) ??
        Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'];

    final controller = useTextEditingController(text: title);
    final isEditing = useState(false);
    final focusNode = useFocusNode();

    useEffect(() {
      focusNode.addListener(() {
        if (!focusNode.hasFocus) {
          isEditing.value = false;
          if (controller.text.isEmpty) {
            controller.text = title ?? "Tab";
          }
        }
      });
      return;
    }, []);

    final theme = ref
        .watch(preferencesProvider.select((value) => value.defaultTheme.value));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: activeRoot != node && !isEditing.value
          ? () {
              terminalTree.setActiveRoot(node);
              scrollController.scrollToIndex(
                index,
                preferPosition: AutoScrollPosition.end,
              );
              node.focusNode.requestFocus();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: activeRoot == node
              ? theme.background.isDark
                  ? theme.background.lighten()
                  : theme.background.darken()
              : null,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: 150,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ReorderableDragStartListener(
                index: index,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isEditing.value)
                      Container(
                        width: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: theme.foreground,
                            width: 1,
                          ),
                        ),
                        child: EditableText(
                          backgroundCursorColor:
                              isDark ? Colors.white : Colors.black,
                          cursorColor: isDark ? Colors.white : Colors.black,
                          selectionColor:
                              Theme.of(context).primaryColor.withOpacity(0.8),
                          focusNode: focusNode,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(fontSize: 14),
                          onEditingComplete: () {
                            isEditing.value = false;
                            terminalTree.focused?.focusNode.requestFocus();
                          },
                          scrollBehavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          controller: controller,
                        ),
                      )
                    else
                      Flexible(
                        child: Tooltip(
                          message: controller.text,
                          child: GestureDetector(
                            onTap: node == terminalTree.active
                                ? () {
                                    isEditing.value = true;
                                    focusNode.requestFocus();
                                  }
                                : null,
                            child: Text(
                              controller.text,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 5),
                    CompactIconButton(
                      onPressed: onClose,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 15,
                      ),
                    )
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
