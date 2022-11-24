import 'dart:convert';
import 'dart:io';

import 'package:wives/extensions/size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wives/hooks/useAutoScrollController.dart';
import 'package:wives/hooks/usePaletteOverlay.dart';
import 'package:wives/hooks/useTabShortcuts.dart';
import 'package:wives/models/cache_keys.dart';
import 'package:wives/models/intents.dart';
import 'package:wives/routes.dart';

Future<SharedPreferences> get localStorage => SharedPreferences.getInstance();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Wives',
    minimumSize: Size(700, 400),
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    final store = await localStorage;
    if (!Platform.isLinux) await windowManager.setHasShadow(true);
    await windowManager.setResizable(true);
    await windowManager.setMinimumSize(const Size(700, 400));
    if (store.getString(CacheKeys.windowSize) != null &&
        store.getBool(CacheKeys.windowMaximized) != true) {
      final size = SizeSerializer.fromJson(
          jsonDecode(store.getString(CacheKeys.windowSize)!));
      await windowManager.setSize(size);
    }
    if (store.getBool(CacheKeys.windowMaximized) == true) {
      await windowManager.maximize();
    }
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
  void onWindowResize() async {
    final store = await localStorage;
    final size = await windowManager.getSize();
    store.setBool(CacheKeys.windowMaximized, await windowManager.isMaximized());
    store.setString(CacheKeys.windowSize, jsonEncode(size.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    final terminalTabScrollController = useAutoScrollController();
    final openPalette = usePaletteOverlay();

    useEffect(() {
      router.go("/", extra: terminalTabScrollController);
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
        SplitViewIntent: SplitViewAction(),
        NavigationIntent: NavigationAction(),
        FontAdjustmentIntent: FontAdjustmentAction(),
        CursorSelectorIntent: CursorSelectorAction(),
        CopyPasteIntent: CopyPasteAction(),
        PaletteIntent: CallbackAction(
          onInvoke: (intent) => openPalette(),
        )
      },
    );
  }
}
