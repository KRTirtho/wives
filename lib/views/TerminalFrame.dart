import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:wives/components/CompactIconButton.dart';
import 'package:wives/components/WindowTitleBar.dart';
import 'package:wives/hooks/useTabShortcuts.dart';
import 'package:wives/main.dart';
import 'package:wives/models/intents.dart';
import 'package:wives/providers/PreferencesProvider.dart';
import 'package:wives/providers/TerminalTree.dart';
import 'package:wives/services/native.dart';
import 'package:flutter/material.dart';
import 'package:wives/components/TerminalSplitGroup.dart';

class TerminalFrame extends HookConsumerWidget {
  final AutoScrollController scrollController;
  const TerminalFrame({
    required this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final shells = NativeUtils.getShells();
    final terminalTree = ref.watch(TerminalTree.provider);

    final activeRoot = terminalTree.active;
    final activeRootIndex = terminalTree.activeIndex;

    void createNewTab([String? shell]) {
      final newNode = terminalTree.createNewTerminalTab(shell);
      scrollController.scrollToIndex(
        terminalTree.nodes.indexOf(newNode),
        preferPosition: AutoScrollPosition.begin,
      );
    }

    void closeTab(int index) {
      terminalTree.closeTerminalTab(terminalTree.nodes[index]);
    }

    final shortcuts = useTabShortcuts(ref, scrollController);

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

    final appBar = WindowTitleBar(
      nonDraggableLeading: Scrollbar(
        controller: scrollController,
        child: ReorderableListView.builder(
          onReorder: (oldIndex, newIndex) {
            terminalTree.reorderTerminalTabs(oldIndex, newIndex);
          },
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
                    color: Theme.of(context).colorScheme.background,
                    width: Tween<double>(begin: 0, end: 2).transform(
                      animation.value,
                    ),
                  ),
                ),
                child: child,
              ),
            );
          },
          footer: Center(
            child: Row(
              children: [
                const SizedBox(width: 5),
                CompactIconButton(
                  onPressed: createNewTab,
                  child: const Icon(Icons.add_rounded),
                ),
                PopupMenuButton<String>(
                  position: PopupMenuPosition.under,
                  onSelected: (value) {
                    if (value == "settings") {
                      GoRouter.of(context).push("/settings");
                    } else {
                      createNewTab(value);
                    }
                  },
                  onCanceled: activeRoot?.focusNode.requestFocus,
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
          ),
          itemBuilder: (context, i) {
            return HookBuilder(
              key: ValueKey(terminalTree.nodes[i]),
              builder: (context) {
                final rootNode = terminalTree.nodes[i];
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
                    }
                  });
                  return;
                }, []);

                return AutoScrollTag(
                  controller: scrollController,
                  index: i,
                  key: ValueKey(terminalTree.nodes[i]),
                  child: InkWell(
                    onTap: activeRoot != rootNode && !isEditing.value
                        ? () {
                            terminalTree.setActiveRoot(rootNode);
                            scrollController.scrollToIndex(
                              i,
                              preferPosition: AutoScrollPosition.end,
                            );
                            rootNode.focusNode.requestFocus();
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: activeRoot == terminalTree.nodes[i]
                            ? Colors.grey[800]
                            : null,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                            child: ReorderableDragStartListener(
                              index: i,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isEditing.value)
                                    SizedBox(
                                      width: 110,
                                      child: EditableText(
                                        backgroundCursorColor: Colors.white,
                                        cursorColor: Colors.white,
                                        selectionColor:
                                            Colors.blue.withAlpha(70),
                                        focusNode: focusNode,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        onEditingComplete: () {
                                          isEditing.value = false;
                                          terminalTree.focused?.focusNode
                                              .requestFocus();
                                        },
                                        scrollBehavior:
                                            ScrollConfiguration.of(context)
                                                .copyWith(scrollbars: false),
                                        controller: controller,
                                      ),
                                    )
                                  else
                                    Flexible(
                                      child: Tooltip(
                                        message: controller.text,
                                        child: GestureDetector(
                                          onTap: rootNode == terminalTree.active
                                              ? () {
                                                  isEditing.value = true;
                                                  focusNode.requestFocus();
                                                }
                                              : null,
                                          child: Text(
                                            controller.text,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 5),
                                  CompactIconButton(
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 15,
                                    ),
                                    onPressed: () => closeTab(i),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
    return Scaffold(
      appBar: appBar,
      body: terminalTree.nodes.isNotEmpty && activeRootIndex != null
          ? terminalTree.nodes.map((tab) {
              final isActive = activeRoot == tab;
              return TerminalSplitGroup(
                node: tab,
                onSecondaryTapDown: (activeNode, info, cell) {
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      info.globalPosition.dx,
                      info.globalPosition.dy,
                      info.globalPosition.distance + info.globalPosition.dx,
                      info.globalPosition.distance + info.globalPosition.dy,
                    ),
                    elevation: 0,
                    items: [
                      PopupMenuItem(
                        value: "copy",
                        height: 30,
                        onTap: () {
                          Actions.of(context).invokeAction(
                            CopyPasteAction(),
                            CopyPasteIntent(
                              activeNode.terminal,
                              controller: activeNode.controller,
                              intentType: CopyPasteIntentType.copy,
                            ),
                          );
                        },
                        child: const ListTile(
                          dense: true,
                          horizontalTitleGap: 0,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(FluentIcons.copy_16_regular),
                          title: Text("Copy"),
                        ),
                      ),
                      PopupMenuItem(
                        value: "paste",
                        height: 30,
                        onTap: () {
                          Actions.of(context).invokeAction(
                            CopyPasteAction(),
                            CopyPasteIntent(
                              activeNode.terminal,
                              controller: activeNode.controller,
                              intentType: CopyPasteIntentType.paste,
                            ),
                          );
                        },
                        child: const ListTile(
                          dense: true,
                          horizontalTitleGap: 0,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(FluentIcons.clipboard_paste_16_regular),
                          title: Text("Paste"),
                        ),
                      ),
                      PopupMenuItem(
                        value: "settings",
                        height: 30,
                        onTap: () {
                          GoRouter.of(context).push("/settings");
                        },
                        child: const ListTile(
                          dense: true,
                          horizontalTitleGap: 0,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(FluentIcons.settings_16_regular),
                          title: Text("Settings"),
                        ),
                      ),
                    ],
                  );
                },
                shortcuts: {
                  if (isActive) ...shortcuts,
                  const SingleActivator(
                    LogicalKeyboardKey.keyC,
                    control: true,
                    shift: true,
                  ): CopyPasteIntent(
                    tab.terminal,
                    intentType: CopyPasteIntentType.copy,
                    controller: tab.controller,
                  ),
                  const SingleActivator(
                    LogicalKeyboardKey.keyV,
                    control: true,
                    shift: true,
                  ): CopyPasteIntent(
                    tab.terminal,
                    intentType: CopyPasteIntentType.paste,
                    controller: tab.controller,
                  ),
                  const SingleActivator(
                    LogicalKeyboardKey.arrowRight,
                    shift: true,
                  ): CursorSelectorIntent(
                    tab,
                    direction: CursorSelectorType.selectRight,
                  ),
                  const SingleActivator(
                    LogicalKeyboardKey.arrowLeft,
                    shift: true,
                  ): CursorSelectorIntent(
                    tab,
                    direction: CursorSelectorType.selectLeft,
                  ),
                  const SingleActivator(LogicalKeyboardKey.arrowLeft):
                      CursorSelectorIntent(
                    tab,
                    direction: CursorSelectorType.clearLeft,
                  ),
                  const SingleActivator(LogicalKeyboardKey.arrowRight):
                      CursorSelectorIntent(
                    tab,
                    direction: CursorSelectorType.clearRight,
                  ),
                },
              );
            }).toList()[activeRootIndex]
          : Container(),
    );
  }
}
