import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wives/components/CommandPalette/PaletteOverlay.dart';

void Function() usePaletteOverlay() {
  final isOpen = useState(false);
  final context = useContext();

  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isOpen.value) {
        showGeneralDialog(
          context: context,
          pageBuilder: (context, animation1, animation2) {
            return const PaletteOverlay();
          },
          transitionDuration: const Duration(milliseconds: 70),
          barrierDismissible: true,
          barrierLabel: "",
        ).then((_) {
          isOpen.value = false;
        });
      }
    });
    return () {};
  }, [isOpen.value]);

  return () => isOpen.value = true;
}
