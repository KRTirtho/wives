import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:window_manager/window_manager.dart';

class WindowTitleBar extends StatefulWidget {
  final Widget? leading;
  final Widget? nonDraggableLeading;
  const WindowTitleBar({
    this.leading,
    this.nonDraggableLeading,
    super.key,
  });

  @override
  State<WindowTitleBar> createState() => _WindowTitleBarState();
}

class _WindowTitleBarState extends State<WindowTitleBar> with WindowListener {
  bool isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.isMaximized().then((maximized) {
      setState(() {
        isMaximized = maximized;
      });
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    setState(() {
      isMaximized = true;
    });
  }

  @override
  void onWindowUnmaximize() {
    setState(() {
      isMaximized = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.nonDraggableLeading != null) widget.nonDraggableLeading!,
        Expanded(
          child: GestureDetector(
            onPanStart: (details) {
              windowManager.startDragging();
            },
            child: widget.leading ?? const Text(""),
          ),
        ),
        GestureDetector(
          onPanStart: (details) {
            windowManager.startDragging();
          },
          child: Row(
            children: [
              WindowCaptionButton.minimize(
                brightness: Brightness.dark,
                onPressed: windowManager.minimize,
              ),
              isMaximized
                  ? WindowCaptionButton.unmaximize(
                      brightness: Brightness.dark,
                      onPressed: windowManager.unmaximize,
                    )
                  : WindowCaptionButton.maximize(
                      brightness: Brightness.dark,
                      onPressed: windowManager.maximize,
                    ),
              WindowCaptionButton.close(
                brightness: Brightness.dark,
                onPressed: windowManager.close,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
