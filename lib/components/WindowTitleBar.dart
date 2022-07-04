import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

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
  Size get preferredSize => appWindow.size;
}

class _WindowTitleBarState extends State<WindowTitleBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Platform.isLinux && !appWindow.isMaximized
          ? const EdgeInsets.only(
              top: 0.5,
              right: 0.5,
              left: 0.5,
            )
          : null,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: Platform.isLinux && !appWindow.isMaximized
            ? const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          // mitigates the bitsdojo_window bug with gtk_window in linux
          borderRadius: Platform.isLinux && !appWindow.isMaximized
              ? const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                )
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: SizedBox(
            height: 45,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.nonDraggableLeading != null)
                  widget.nonDraggableLeading!,
                Expanded(
                  child: GestureDetector(
                    onPanUpdate: (_) => appWindow.startDragging(),
                    onPanEnd: (_) {
                      setState(() {});
                    },
                    child: widget.leading ?? const Text(""),
                  ),
                ),
                if (widget.center != null)
                  GestureDetector(
                    onPanUpdate: (_) => appWindow.startDragging(),
                    child: widget.center,
                  ),
                GestureDetector(
                  onPanUpdate: (_) => appWindow.startDragging(),
                  child: Row(
                    children: [
                      MinimizeWindowButton(
                        onPressed: appWindow.minimize,
                      ),
                      MaximizeWindowButton(
                        onPressed: () {
                          appWindow.maximizeOrRestore();
                          setState(() {});
                        },
                      ),
                      CloseWindowButton(
                        onPressed: appWindow.close,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
