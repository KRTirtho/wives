import 'package:flutter/animation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

VoidCallback useForceUpdate() {
  final state = useState(false);

  return () => state.value = !state.value;
}
