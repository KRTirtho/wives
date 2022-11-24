import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wives/components/CommandPalette/palette_overlay.dart';
import 'package:wives/routes.dart';

void Function() usePaletteOverlay() {
  final isOpen = useState(false);
  final context = routerKey.currentState?.overlay?.context;

  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isOpen.value && context != null) {
        showGeneralDialog(
          context: context,
          pageBuilder: (context, animation1, animation2) {
            return const PaletteOverlay();
          },
          transitionDuration: const Duration(milliseconds: 70),
          barrierDismissible: true,
          barrierLabel: "",
          barrierColor: Colors.black26,
        ).then((_) {
          isOpen.value = false;
        });
      }
    });
    return () {};
  }, [isOpen.value]);

  return () => isOpen.value = true;
}
