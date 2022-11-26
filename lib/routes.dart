import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wives/views/color_scheme_picker.dart';
import 'package:wives/views/terminal_frame.dart';
import 'package:wives/views/terminal_settings.dart';

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
          pageBuilder: (context, state) => const MaterialPage(
            child: ColorSchemePicker(),
          ),
        ),
      ],
    ),
  ],
);
