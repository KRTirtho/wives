import 'dart:convert';
import 'dart:io';

import 'package:wives/extensions/size.dart';
import 'package:wives/extensions/color.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wives/models/cache_keys.dart';
import 'package:wives/providers/preferences_provider.dart';
import 'package:wives/providers/shortcuts_provider.dart';
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
    final shortcuts = ref.watch(
      TerminalShortcuts.provider.notifier.select(
        (s) => s.rootActions.map((s) {
          return MapEntry(s.shortcut!, TerminalIntent(context, s));
        }),
      ),
    );

    final theme =
        ref.watch(preferencesProvider.select((s) => s.defaultTheme.value));

    final background = theme.background.isDark
        ? theme.background.darken()
        : theme.background.lighten();

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Terminal',
      builder: (context, child) => DragToResizeArea(
        child: Platform.isLinux
            ? DragToResizeArea(
                resizeEdgeColor: Colors.white,
                resizeEdgeSize: 0.2,
                child: child!,
              )
            : child!,
      ),
      darkTheme: ThemeData.dark().copyWith(
        backgroundColor: background,
        primaryColor: theme.blue,
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: background,
        dialogBackgroundColor: background,
        popupMenuTheme: PopupMenuThemeData(
          color: background,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        splashFactory: NoSplash.splashFactory,
        buttonTheme: ButtonThemeData(
          hoverColor: Colors.grey.withOpacity(0.2),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.blue,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: 2,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.blue,
              width: 2,
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.dark,
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        ...Map.fromEntries(shortcuts),
      },
      actions: {
        ...WidgetsApp.defaultActions,
        TerminalIntent: TerminalIntentAction(),
      },
    );
  }
}
