import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wives/hooks/useAutoScrollController.dart';
import 'package:wives/hooks/usePaletteOverlay.dart';
import 'package:wives/hooks/useTabShortcuts.dart';
import 'package:wives/models/intents.dart';
import 'package:wives/providers/TerminalProvider.dart';
import 'package:wives/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Wives',
    minimumSize: Size(700, 400),
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (!Platform.isLinux) await windowManager.setHasShadow(true);
    await windowManager.setResizable(true);
    await windowManager.setMinimumSize(const Size(700, 400));
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const ProviderScope(child: Terminal()));
}

class Terminal extends StatefulHookConsumerWidget {
  const Terminal({Key? key}) : super(key: key);

  @override
  ConsumerState<Terminal> createState() => _TerminalState();
}

class _TerminalState extends ConsumerState<Terminal> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowFocus() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final terminalTabScrollController = useAutoScrollController();
    final openPalette = usePaletteOverlay();

    useEffect(() {
      router.go("/", extra: terminalTabScrollController);
      ref.read(terminalProvider).terminalAt(0)?.key.requestFocus();
      return null;
    }, []);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Terminal',
      builder: (context, child) => DragToResizeArea(
        child: child!,
      ),
      darkTheme: ThemeData.dark().copyWith(
        backgroundColor: Colors.black,
        scaffoldBackgroundColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        buttonTheme: ButtonThemeData(
          hoverColor: Colors.grey.withOpacity(0.2),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.dark,
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        const SingleActivator(LogicalKeyboardKey.comma, control: true):
            const NavigationIntent(path: "/settings"),
        const SingleActivator(LogicalKeyboardKey.equal, control: true):
            FontAdjustmentIntent(ref: ref, adjustment: 1),
        const SingleActivator(LogicalKeyboardKey.minus, control: true):
            FontAdjustmentIntent(ref: ref, adjustment: -1),
        const SingleActivator(
          LogicalKeyboardKey.keyP,
          control: true,
          shift: true,
        ): const PaletteIntent(),
        ...useTabShortcuts(ref, terminalTabScrollController),
      },
      actions: {
        ...WidgetsApp.defaultActions,
        TabIntent: TabAction(),
        NavigationIntent: NavigationAction(),
        FontAdjustmentIntent: FontAdjustmentAction(),
        CopyPasteIntent: CopyPasteAction(),
        PaletteIntent: CallbackAction(
          onInvoke: (intent) => openPalette(),
        )
      },
    );
  }
}
