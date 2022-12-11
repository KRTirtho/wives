import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wives/misc/settings_slide_page.dart';
import 'package:wives/views/settings/about.dart';
import 'package:wives/views/settings/color_scheme_picker.dart';
import 'package:wives/views/settings/keyboard_shortcuts_editor.dart';
import 'package:wives/views/terminal_frame.dart';
import 'package:wives/views/settings/terminal_settings.dart';

final routerKey = GlobalKey<NavigatorState>();
final router = GoRouter(
  navigatorKey: routerKey,
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const MaterialPage(
        child: TerminalFrame(),
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => const MaterialPage(
        child: TerminalSettings(),
      ),
      routes: [
        GoRoute(
          path: 'color-scheme',
          pageBuilder: (context, state) => SettingsSlidePage(
            child: const ColorSchemePicker(),
          ),
        ),
        GoRoute(
          path: 'keyboard-shortcuts',
          pageBuilder: (context, state) => SettingsSlidePage(
            child: const KeyboardShortcutEditor(),
          ),
        ),
        GoRoute(
          path: 'about',
          pageBuilder: (context, state) => SettingsSlidePage(
            child: const AboutWives(),
          ),
        ),
      ],
    ),
  ],
);
