import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:wives/components/CompactIconButton.dart';
import 'package:wives/components/WindowTitleBar.dart';
import 'package:wives/hooks/useTabShortcuts.dart';
import 'package:wives/models/intents.dart';
import 'package:wives/providers/TerminalTree.dart';
import 'package:wives/services/native.dart';
import 'package:flutter/material.dart';
import 'package:wives/views/Grouper.dart';

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        terminalTree.createNewTerminalTab();
      });
      return null;
    }, []);

    final appBar = WindowTitleBar(
      nonDraggableLeading: Scrollbar(
        controller: scrollController,
        child: ListView.builder(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: terminalTree.nodes.length + 1,
          itemBuilder: (context, i) {
            if (terminalTree.nodes.length == i) {
              return Center(
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
                                      leading:
                                          const Icon(Icons.terminal_rounded),
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
              );
            }

            final tab = "Terminal $i";
            final rootNode = terminalTree.nodes[i];
            return AutoScrollTag(
              controller: scrollController,
              index: i,
              key: ValueKey(i),
              child: InkWell(
                onTap: activeRoot != rootNode
                    ? () {
                        terminalTree.setActiveRoot(rootNode);
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
                    color: activeRoot == terminalTree.nodes[i]
                        ? Colors.grey[800]
                        : null,
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
    );
    return Scaffold(
      appBar: appBar,
      body: terminalTree.nodes.isNotEmpty && activeRootIndex != null
          ? terminalTree.nodes.map((tab) {
              final isActive = activeRoot == tab;
              return Grouper(
                node: tab,
                onSecondaryTapDown: (info, cell) {
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
                              CopyPasteIntent(tab.terminal,
                                  controller: tab.controller,
                                  intentType: CopyPasteIntentType.copy));
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
                              CopyPasteIntent(tab.terminal,
                                  controller: tab.controller,
                                  intentType: CopyPasteIntentType.paste));
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
                },
              );
            }).toList()[activeRootIndex]
          : Container(),
    );
  }
}
