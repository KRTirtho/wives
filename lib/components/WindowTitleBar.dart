import 'dart:ui';

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
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor.withOpacity(0.7),
        // mitigates the bitsdojo_window bug with gtk_window in linux
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.nonDraggableLeading != null)
                widget.nonDraggableLeading!,
              Expanded(
                child: GestureDetector(
                  onPanUpdate: (_) => appWindow.startDragging(),
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
    );
  }
}
