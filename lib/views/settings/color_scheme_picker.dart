import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tuple/tuple.dart';
import 'package:wives/components/scheme_tile.dart';
import 'package:wives/components/window_title_bar.dart';
import 'package:wives/providers/preferences_provider.dart';
import 'package:wives/providers/terminal_theme_provider.dart';
import 'package:wives/extensions/color.dart';
import 'package:xterm/ui.dart';
import 'package:collection/collection.dart';

class ColorSchemePicker extends HookConsumerWidget {
  const ColorSchemePicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final theme = ref.watch(preferencesProvider.select((p) => p.defaultTheme));
    final themesFuture = ref.watch(themesProvider);
    final searchText = useState('');
    final controller = useTabController(initialLength: 2);
    final index = useState(0);
    final isDark = ref.watch(preferencesProvider.select((s) => s.isDark));

    useEffect(() {
      listener() {
        index.value = controller.index;
      }

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    final filteredSchemes = useMemoized(
      () => themesFuture.asData?.value.entries
          .map((e) => Tuple2(weightedRatio(e.key, searchText.value), e))
          .sorted((a, b) => b.item1.compareTo(a.item1))
          .map((e) => e.item2)
          .toList(),
      [themesFuture, searchText.value],
    );

    Widget filtered() => Center(
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              ...?filteredSchemes?.toList().map((entry) {
                final isDark = entry.value.background.isDark ||
                    entry.key.toLowerCase().endsWith("dark");

                return SchemeTile(
                  foreground: isDark ? Colors.white : Colors.black,
                  theme: entry,
                  brightness: isDark ? Brightness.dark : Brightness.light,
                  key: ValueKey(entry.key),
                );
              })
            ],
          ),
        );

    Widget dark() => Center(
            child: themesFuture.when(
          data: (themes) {
            final filteredThemes = Map<String, TerminalTheme>.from(themes)
              ..removeWhere((key, value) {
                return value.background.isLight ||
                    key.toLowerCase().endsWith("light");
              });

            return Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: filteredThemes.entries
                  .map(
                    (entry) => SchemeTile(
                      foreground: isDark
                          ? entry.value.foreground
                          : entry.value.foreground,
                      theme: entry,
                      brightness: Brightness.dark,
                      key: ValueKey(entry.key),
                    ),
                  )
                  .toList(),
            );
          },
          error: (error, stackTrace) => const Text("Failed to load themes"),
          loading: () => const Center(child: CircularProgressIndicator()),
        ));
    Widget light() => Center(
            child: themesFuture.when(
          data: (themes) {
            final filteredThemes = Map<String, TerminalTheme>.from(themes)
              ..removeWhere((key, value) {
                return value.background.isDark ||
                    key.toLowerCase().endsWith("dark");
              });

            return Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: filteredThemes.entries
                  .map(
                    (entry) => SchemeTile(
                      theme: entry,
                      brightness: Brightness.light,
                      foreground: isDark
                          ? entry.value.background
                          : entry.value.foreground,
                      key: ValueKey(entry.key),
                    ),
                  )
                  .toList(),
            );
          },
          error: (error, stackTrace) => const Text("Failed to load themes"),
          loading: () => const Center(child: CircularProgressIndicator()),
        ));
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Default",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    SchemeTile(
                      theme: theme,
                      brightness: Brightness.dark,
                      foreground: isDark
                          ? theme.value.foreground
                          : theme.value.foreground,
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(FluentIcons.arrow_shuffle_16_regular),
                      label: const Text("Select Random"),
                      onPressed: () {
                        final themes = themesFuture.asData?.value.entries
                            .toList()
                          ?..shuffle();
                        final random = themes?.first;
                        if (random != null) {
                          ref.read(preferencesProvider).setDefaultTheme(random);
                          final isDark = random.value.background.isDark ||
                              random.key.toLowerCase().endsWith("dark");
                          ref.read(preferencesProvider).setThemeMode(
                              isDark ? ThemeMode.dark : ThemeMode.light);
                        }
                      },
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Text(
                      "Available Color Schemes",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    Expanded(
                      child: TextField(
                        onChanged: (value) => searchText.value = value,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(FluentIcons.search_24_regular),
                          hintText: "Search...",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                if (searchText.value.isEmpty) ...[
                  TabBar(
                    controller: controller,
                    tabs: [
                      Tab(
                        child: Row(
                          children: const [
                            Icon(Icons.dark_mode_outlined),
                            SizedBox(width: 5),
                            Text("Dark"),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          children: const [
                            Icon(FluentIcons.brightness_high_16_regular),
                            SizedBox(width: 5),
                            Text("Light"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (index.value == 0) dark(),
                  if (index.value == 1) light(),
                ] else
                  filtered(),
              ],
            ),
          ),
        ));
  }
}
