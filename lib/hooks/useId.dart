import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nanoid/nanoid.dart';

String useId([String? id]) {
  return useMemoized(() => id ?? nanoid(), [id]);
}
