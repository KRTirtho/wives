import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wives/components/platform_titlebar_buttons.dart';

class WindowTitleBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? center;
  final Widget? nonDraggableLeading;
  const WindowTitleBar({
    this.leading,
    this.center,
    this.nonDraggableLeading,
    super.key,
  });

  @override
  State<WindowTitleBar> createState() => _WindowTitleBarState();

  @override
  Size get preferredSize => const Size.fromHeight(55);
}

class _WindowTitleBarState extends State<WindowTitleBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[800]),
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
        child: Material(
          type: MaterialType.transparency,
          child: SizedBox(
            height: 45,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.nonDraggableLeading != null)
                  widget.nonDraggableLeading!,
                Expanded(
                  child: DragToMoveArea(
                    child: widget.leading ?? const Text(""),
                  ),
                ),
                if (widget.center != null)
                  DragToMoveArea(
                    child: widget.center!,
                  ),
                DragToMoveArea(
                  child: Platform.isWindows
                      ? const WindowsTitleButtons()
                      : const LinuxTitleButtons(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
