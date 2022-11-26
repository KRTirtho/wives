import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/components/SchemeTile.dart';
import 'package:wives/components/window_title_bar.dart';
import 'package:wives/providers/preferences_provider.dart';
import 'package:wives/providers/terminal_theme_provider.dart';

class ColorSchemePicker extends HookConsumerWidget {
  const ColorSchemePicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final theme = ref.watch(preferencesProvider.select((p) => p.defaultTheme));
    final themesFuture = ref.watch(themesProvider);

    return Scaffold(
        backgroundColor: theme.value.background,
        appBar: WindowTitleBar(
          nonDraggableLeading: const BackButton(),
          leading: Center(
            child: Text(
              "Color Scheme",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Default",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 5),
                SchemeTile(theme: theme),
                const Divider(),
                Text(
                  "Available Color Schemes",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 5),
                Center(
                    child: themesFuture.when(
                  data: (themes) {
                    return Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.spaceBetween,
                      runAlignment: WrapAlignment.spaceBetween,
                      children: themes.entries
                          .map(
                            (entry) => SchemeTile(
                              theme: entry,
                              key: ValueKey(entry.key),
                            ),
                          )
                          .toList(),
                    );
                  },
                  error: (error, stackTrace) =>
                      const Text("Failed to load themes"),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                )),
              ],
            ),
          ),
        ));
  }
}
