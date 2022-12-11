import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class SettingsSlidePage extends CustomTransitionPage {
  SettingsSlidePage({
    required super.child,
    super.key,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).chain(
                  CurveTween(curve: Curves.easeOut),
                ),
              ),
              child: child,
            );
          },
        );
}
