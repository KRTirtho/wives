import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/components/custom_tiles.dart';
import 'package:wives/components/scheme_tile.dart';
import 'package:wives/components/window_title_bar.dart';
import 'package:wives/providers/preferences_provider.dart';
import 'package:wives/services/native.dart';
import 'package:wives/extensions/color.dart';

class TerminalSettings extends HookConsumerWidget {
  const TerminalSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final cwdController = useTextEditingController();

    final preferences = ref.watch(preferencesProvider);
    final shells = useMemoized(() => NativeUtils.getShells(), []);

    const gap = SizedBox(height: 10);

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
      body: ListTileTheme(
        tileColor: preferences.defaultTheme.value.background.isDark
            ? preferences.defaultTheme.value.background.lighten()
            : preferences.defaultTheme.value.background.darken(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        minLeadingWidth: 0,
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  ListTile(
                    title: const Text("Font Size"),
                    leading: const Icon(FluentIcons.text_font_size_24_regular),
                    minVerticalPadding: 20,
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
                  gap,
                  ListTile(
                    title: const Text("Font family"),
                    leading: const Icon(FluentIcons.text_font_info_16_regular),
                    trailing: DropdownButton<String>(
                      value: preferences.fontFamily,
                      items: fontFamilies
                          .map(
                            (fontFamily) => DropdownMenuItem(
                              value: fontFamily,
                              child: Text(
                                fontFamily,
                                style: TextStyle(fontFamily: fontFamily),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (fontFamily) {
                        if (fontFamily != null) {
                          preferences.setFontFamily(fontFamily);
                        }
                      },
                    ),
                  ),
                  gap,
                  ListTile(
                    title: const Text("Default Shell"),
                    leading: const Icon(FluentIcons.window_16_regular),
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
                  gap,
                  ListTile(
                    title: const Text("Color Scheme"),
                    leading: const Icon(FluentIcons.color_16_regular),
                    onTap: () {
                      GoRouter.of(context).push("/settings/color-scheme");
                    },
                    trailing: const Icon(FluentIcons.chevron_right_12_regular),
                  ),
                  gap,
                  ListTile(
                    title: const Text("Keyboard Shortcuts"),
                    leading: const Icon(FluentIcons.keyboard_16_regular),
                    onTap: () {
                      GoRouter.of(context).push("/settings/keyboard-shortcuts");
                    },
                    trailing: const Icon(FluentIcons.chevron_right_12_regular),
                  ),
                  gap,
                  ListTile(
                    leading: const Icon(FluentIcons.folder_16_regular),
                    title: const Text("Default Working Directory"),
                    minVerticalPadding: 20,
                    trailing: TextField(
                      controller: cwdController,
                      onSubmitted: (value) {
                        preferences.setDefaultWorkingDirectory(value);
                      },
                      decoration: InputDecoration(
                        constraints: const BoxConstraints(maxWidth: 400),
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
                  gap,
                  // switch for turning update checker on or off
                  SwitchListTile.adaptive(
                    secondary:
                        const Icon(FluentIcons.arrow_repeat_1_16_regular),
                    activeColor: preferences.defaultTheme.value.blue,
                    title: const Text("Check for updates"),
                    value: preferences.checkUpdate == true,
                    onChanged: (value) {
                      preferences.setCheckUpdate(value);
                    },
                  ),
                  gap,
                  ListTile(
                    tileColor: preferences.defaultTheme.value.brightRed,
                    title: const Text("About Wives"),
                    leading: const Icon(FluentIcons.info_12_regular),
                    trailing: const Icon(FluentIcons.chevron_right_12_regular),
                    onTap: () => GoRouter.of(context).push("/settings/about"),
                  ),
                  gap
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
