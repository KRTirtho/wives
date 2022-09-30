import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:wives/views/TerminalFrame.dart';
import 'package:wives/views/TerminalSettings.dart';
import 'package:wives/views/TerminalSplitView.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => MaterialPage(
        child: TerminalFrame(
          scrollController: state.extra as AutoScrollController,
        ),
      ),
    ),
    GoRoute(
      path: "/split",
      pageBuilder: (context, state) {
        return const MaterialPage(child: TerminalSplitView());
      },
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => const MaterialPage(
        child: TerminalSettings(),
      ),
    ),
  ],
);
