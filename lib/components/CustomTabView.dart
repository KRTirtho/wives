import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wives/components/WindowTitleBar.dart';

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

    useEffect(() {
      if (tabs.length != children.length) {
        throw Exception(
            "Length of tabs & children should be equal but found ${tabs.length} tabs but ${children.length} children");
      }
      return null;
    }, [tabs, children]);

    return Column(
      children: [
        // tabs bar
        WindowTitleBar(
          leading: Material(
            color: Theme.of(context).backgroundColor,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () {
                    final index = onNewTab?.call();

                    if (index != null) activeIndex.value = index;
                  },
                ),
                Row(
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
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(children: [
                                tab,
                                IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  iconSize: 15,
                                  onPressed: () {
                                    if (children.length <= 1) return;
                                    // closes the Tab/Removes the tab
                                    final index = onClose?.call(i);
                                    if (index != null) {
                                      activeIndex.value = index;
                                    }
                                  },
                                )
                              ]),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        // current widget
        children[activeIndex.value],
      ],
    );
  }
}
