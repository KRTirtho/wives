import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wives/extensions/color.dart';
import 'package:wives/providers/preferences_provider.dart';

class WindowsTitleButtons extends StatelessWidget {
  const WindowsTitleButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButtonTheme(
      data: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: EdgeInsets.zero,
            maximumSize: const Size(40, 40),
            minimumSize: const Size(40, 40),
            backgroundColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            )),
      ),
      child: IconTheme(
        data: const IconThemeData(size: 18),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: windowManager.minimize,
              child: const Icon(Icons.minimize),
            ),
            ElevatedButton(
              child: const Icon(Icons.check_box_outline_blank),
              onPressed: () async {
                await windowManager.isMaximized()
                    ? await windowManager.unmaximize()
                    : await windowManager.maximize();
              },
            ),
            ElevatedButton(
              onPressed: windowManager.close,
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.red),
              ),
              child: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}

class LinuxTitleButtons extends ConsumerWidget {
  const LinuxTitleButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final theme =
        ref.watch(preferencesProvider.select((p) => p.defaultTheme.value));

    return ElevatedButtonTheme(
      data: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.all(10),
          maximumSize: const Size(30, 30),
          minimumSize: const Size(30, 30),
          backgroundColor: theme.background.isDark
              ? theme.background.lighten()
              : theme.background.darken(),
          splashFactory: NoSplash.splashFactory,
          shape: const CircleBorder(),
        ),
      ),
      child: IconTheme(
        data: const IconThemeData(size: 14),
        child: Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: windowManager.minimize,
                child: const FittedBox(
                  child: Icon(Icons.minimize),
                ),
              ),
              ElevatedButton(
                child: const FittedBox(
                  child: Icon(Icons.check_box_outline_blank),
                ),
                onPressed: () async {
                  await windowManager.isMaximized()
                      ? await windowManager.unmaximize()
                      : await windowManager.maximize();
                },
              ),
              ElevatedButton(
                onPressed: windowManager.close,
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.red),
                ),
                child: const FittedBox(
                  child: Icon(Icons.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
