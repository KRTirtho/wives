import 'package:flutter/cupertino.dart';
import 'package:wives/routes.dart';

class NavigationIntent extends Intent {
  final String path;
  const NavigationIntent({
    required this.path,
  });
}

class NavigationAction extends Action<NavigationIntent> {
  @override
  void invoke(intent) {
    router.push("/settings");
  }
}
