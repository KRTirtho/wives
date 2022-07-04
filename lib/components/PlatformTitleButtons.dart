import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

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
            primary: Colors.transparent,
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
              onPressed: appWindow.minimize,
              child: const Icon(Icons.minimize),
            ),
            ElevatedButton(
              child: const Icon(Icons.check_box_outline_blank),
              onPressed: () {
                appWindow.maximizeOrRestore();
              },
            ),
            ElevatedButton(
              onPressed: appWindow.close,
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

class LinuxTitleButtons extends StatelessWidget {
  const LinuxTitleButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButtonTheme(
      data: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.all(10),
          maximumSize: const Size(30, 30),
          minimumSize: const Size(30, 30),
          primary: Colors.grey[800],
          splashFactory: NoSplash.splashFactory,
          shape: const CircleBorder(),
        ),
      ),
      child: IconTheme(
        data: const IconThemeData(size: 12),
        child: Padding(
          padding: const EdgeInsets.only(top: 10, right: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: appWindow.minimize,
                child: const Icon(Icons.minimize),
              ),
              ElevatedButton(
                child: const Icon(Icons.check_box_outline_blank),
                onPressed: () {
                  appWindow.maximizeOrRestore();
                },
              ),
              ElevatedButton(
                onPressed: appWindow.close,
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.red),
                ),
                child: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
