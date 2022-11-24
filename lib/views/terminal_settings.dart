import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/components/custom_tiles.dart';
import 'package:wives/components/window_title_bar.dart';
import 'package:wives/providers/preferences_provider.dart';
import 'package:wives/services/native.dart';

class TerminalSettings extends HookConsumerWidget {
  const TerminalSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final cwdController = useTextEditingController();

    final preferences = ref.watch(preferencesProvider);
    final shells = useMemoized(() => NativeUtils.getShells(), []);

    return Scaffold(
      appBar: WindowTitleBar(
        leading: Center(
            child: Text(
          "Settings",
          style: Theme.of(context).textTheme.headline6,
        )),
        nonDraggableLeading: const BackButton(),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        children: [
          ListTile(
            title: const Text("Font Size"),
            trailing: SizedBox(
              height: 60,
              width: 130,
              child: SpinBox(
                min: 5,
                max: 70,
                value: preferences.fontSize,
                iconColor: MaterialStateProperty.all(
                  Theme.of(context).iconTheme.color,
                ),
                onChanged: (size) => preferences.setFontSize(size),
              ),
            ),
          ),
          ListTile(
            title: const Text("Font family"),
            trailing: DropdownButton<String>(
              value: preferences.fontFamily,
              items: fontFamilies
                  .map(
                    (fontFamily) => DropdownMenuItem(
                      value: fontFamily,
                      child: Text(fontFamily),
                    ),
                  )
                  .toList(),
              onChanged: (fontFamily) {
                if (fontFamily != null) preferences.setFontFamily(fontFamily);
              },
            ),
          ),
          ListTile(
            title: const Text("Default Shell"),
            trailing: DropdownButton<String>(
              value: preferences.defaultShell,
              items: shells
                  .map((shell) => DropdownMenuItem(
                        value: shell,
                        child: Text(shell),
                      ))
                  .toList(),
              onChanged: (shell) {
                if (shell != null) preferences.setDefaultShell(shell);
              },
            ),
          ),
          CustomTile(
            title: const Flexible(
              flex: 5,
              child: Text("Default Working Directory"),
            ),
            trailing: Expanded(
              flex: 4,
              child: TextField(
                controller: cwdController,
                onSubmitted: (value) {
                  preferences.setDefaultWorkingDirectory(value);
                },
                decoration: InputDecoration(
                  suffix: ElevatedButton(
                    child: const Icon(Icons.save_rounded),
                    onPressed: () {
                      preferences.setDefaultWorkingDirectory(
                        cwdController.value.text,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
