// TODO: implement Search for Terminal

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wives/components/compact_icon_button.dart';

class SearchOverlay extends HookWidget {
  final void Function()? onClose;
  final void Function(String searchString)? onSearch;
  final void Function(Object options)? onUpdateSearchOptions;
  final FocusNode focusNode;
  SearchOverlay({
    this.onClose,
    this.onSearch,
    this.onUpdateSearchOptions,
    FocusNode? focusNode,
    Key? key,
  })  : focusNode = focusNode ?? FocusNode(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final showUpperCase = useState(false);
    final matchWholeWords = useState(false);
    final useRegex = useState(false);

    updateOptions() {
      // onUpdateSearchOptions?.call(TerminalSearchOptions(
      //   caseSensitive: showUpperCase.value,
      //   matchWholeWord: matchWholeWords.value,
      //   useRegex: useRegex.value,
      // ));
    }

    useEffect(() {
      listener() {
        if (!focusNode.hasFocus) {
          onClose?.call();
        }
      }

      focusNode.addListener(listener);
      return () {
        focusNode.removeListener(listener);
      };
    }, []);

    return Align(
      alignment: Alignment.topRight,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          height: 60,
          width: 400,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withOpacity(.5),
          ),
          margin: const EdgeInsets.only(
            top: 60,
            right: 10,
          ),
          clipBehavior: Clip.hardEdge,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.escape): () {
                  onClose?.call();
                },
              },
              child: TextField(
                focusNode: focusNode,
                onChanged: onSearch,
                decoration: InputDecoration(
                    suffix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CompactIconButton(
                      child: Icon(Icons.text_fields_rounded,
                          color: showUpperCase.value ? Colors.blue : null),
                      onPressed: () {
                        showUpperCase.value = !showUpperCase.value;
                        updateOptions();
                      },
                    ),
                    const SizedBox(width: 5),
                    CompactIconButton(
                      child: Icon(Icons.text_format_rounded,
                          color: matchWholeWords.value ? Colors.blue : null),
                      onPressed: () {
                        matchWholeWords.value = !matchWholeWords.value;
                        updateOptions();
                      },
                    ),
                    const SizedBox(width: 5),
                    CompactIconButton(
                      child: Icon(Icons.password_rounded,
                          color: useRegex.value ? Colors.blue : null),
                      onPressed: () {
                        useRegex.value = !useRegex.value;
                        updateOptions();
                      },
                    ),
                  ],
                )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void useSearchOverlay(
  bool isOpen, {
  void Function()? onClose,
  void Function(String searchString)? onSearch,
  void Function(Object options)? onUpdateSearchOptions,
}) {
  final context = useContext();
  final focusNode = useFocusNode();

  final entryRef = useRef<OverlayEntry?>(null);

  void disposeOverlay() {
    try {
      entryRef.value?.remove();
      entryRef.value = null;
    } catch (e, stack) {
      if (e is! AssertionError) {
        print("useEffect.cleanup $e");
        print(stack);
      }
    }
  }

  useEffect(() {
    // I can't believe useEffect doesn't run Post Frame aka
    // after rendering/painting the UI
    // `My disappointment is immeasurable and my day is ruined` XD
    WidgetsBinding.instance.addPostFrameCallback((time) {
      // clearing the overlay-entry as passing the already available
      // entry will result in splashing while resizing the window

      if (isOpen) {
        entryRef.value = OverlayEntry(
          opaque: false,
          builder: (context) => SearchOverlay(
            onClose: onClose,
            onSearch: onSearch,
            onUpdateSearchOptions: onUpdateSearchOptions,
            focusNode: focusNode,
          ),
        );
        try {
          Overlay.of(context)?.insert(entryRef.value!);
          focusNode.requestFocus();
        } catch (e) {
          if (e is AssertionError &&
              e.message ==
                  'The specified entry is already present in the Overlay.') {
            disposeOverlay();
            Overlay.of(context)?.insert(entryRef.value!);
          }
        }
      } else {
        disposeOverlay();
      }
    });
    return () {
      disposeOverlay();
    };
  }, [isOpen]);
}
