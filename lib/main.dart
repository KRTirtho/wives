import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:window_size/window_size.dart';
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

  setWindowMinSize(const Size(700, 400));
  const windowOptions = WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Wives',
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    final store = await localStorage;
    if (!Platform.isLinux) await windowManager.setHasShadow(true);
    await windowManager.setResizable(true);
    final rawSize = store.getString(CacheKeys.windowSize);
    final wasMaximized = store.getBool(CacheKeys.windowMaximized) == true;
    if (rawSize != null && !wasMaximized) {
      var size = SizeSerializer.fromJson(
        jsonDecode(store.getString(CacheKeys.windowSize)!),
      );
      if (Platform.isLinux && kReleaseMode) {
        size = Size(size.width + 70, size.height + 70);
      }
      await windowManager.setSize(size, animate: true);
    } else {
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
  ConsumerState<Terminal> createState() => TerminalState();
}

class TerminalState extends ConsumerState<Terminal>
    with WidgetsBindingObserver {
  Size? prevSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() async {
    final store = await localStorage;
    final size = WidgetsBinding.instance.window.physicalSize;
    final windowSameDimension =
        prevSize?.width == size.width && prevSize?.height == size.height;
    if (windowSameDimension) return;
    await store.setBool(
      CacheKeys.windowMaximized,
      await windowManager.isMaximized(),
    );
    await store.setString(CacheKeys.windowSize, jsonEncode(size.toJson()));
    prevSize = size;
    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      TerminalShortcuts.provider,
      (previous, next) {
        if (previous != next) {
          setState(() {});
        }
      },
    );
    final shortcuts = ref.watch(
      TerminalShortcuts.provider.notifier.select(
        (s) => s.rootActions.map((s) {
          return MapEntry(s.shortcut!, TerminalIntent(context, s));
        }),
      ),
    );

    final theme =
        ref.watch(preferencesProvider.select((s) => s.defaultTheme.value));
    final themeMode = ref.watch(preferencesProvider.select((s) => s.themeMode));

    final background = theme.background.isDark
        ? theme.background.darken()
        : theme.background.lighten();

    final themeData = ThemeData(
      brightness:
          themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      backgroundColor: background,
      primaryColor: theme.blue,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: background,
      dialogBackgroundColor: background,
      popupMenuTheme: PopupMenuThemeData(
        color: background,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: theme.blue,
        unselectedLabelColor: theme.blue.lighten(),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border:
              Border.fromBorderSide(BorderSide(color: theme.blue, width: 2)),
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
    );

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Terminal',
      builder: (context, child) {
        return DragToResizeArea(
          child: Platform.isLinux
              ? DragToResizeArea(
                  resizeEdgeColor: Colors.white,
                  resizeEdgeSize: 0.2,
                  child: child!,
                )
              : child!,
        );
      },
      darkTheme: themeData,
      theme: themeData,
      themeMode: themeMode,
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
