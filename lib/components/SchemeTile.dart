import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/providers/preferences_provider.dart';
import 'package:xterm/ui.dart';
import 'package:wives/extensions/color.dart';

final borderRadius = BorderRadius.circular(5);

class SchemeTile extends HookConsumerWidget {
  final MapEntry<String, TerminalTheme> theme;
  const SchemeTile({
    required this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final selected = ref.watch(
        preferencesProvider.select((s) => s.defaultTheme.key == theme.key));

    final tabColor = theme.value.background.isDark
        ? theme.value.background.lighten()
        : theme.value.background.darken();

    final tabbarColor = theme.value.background.isDark
        ? theme.value.background.darken()
        : theme.value.background.lighten();

    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: borderRadius,
              onTap: () => ref.read(preferencesProvider).setDefaultTheme(theme),
              child: Container(
                height: 115,
                width: 180,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  color: theme.value.background,
                  border: selected
                      ? Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 20,
                      decoration: BoxDecoration(
                        color: tabbarColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 5),
                          Container(
                            height: 10,
                            width: 30,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: tabColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.close, size: 5),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            height: 10,
                            width: 10,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: tabColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.minimize_sharp, size: 5),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Container(
                            height: 10,
                            width: 10,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: tabColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.check_box_outline_blank_sharp,
                                  size: 5),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Container(
                            height: 10,
                            width: 10,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: tabColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.close, size: 5),
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0)
                          .copyWith(bottom: 0, right: 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ColorResin(
                                  width: 30, color: theme.value.brightBlue),
                              const SizedBox(width: 5),
                              ColorResin(
                                  width: 20, color: theme.value.brightMagenta),
                              const SizedBox(width: 7),
                              ColorResin(width: 20, color: theme.value.white),
                              const SizedBox(width: 10),
                              ColorResin(width: 30, color: theme.value.white),
                              const SizedBox(width: 10),
                              ColorResin(width: 15, color: theme.value.red),
                            ],
                          ),
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              ColorResin(
                                  width: 40, color: theme.value.brightRed),
                              const SizedBox(width: 5),
                              ColorResin(
                                  width: 20, color: theme.value.brightWhite),
                              const SizedBox(width: 10),
                              ColorResin(width: 15, color: theme.value.white),
                              const SizedBox(width: 10),
                              ColorResin(
                                  width: 30, color: theme.value.brightYellow),
                            ],
                          ),
                          Row(
                            children: [
                              ColorResin(
                                  width: 15, color: theme.value.brightBlack),
                              const SizedBox(width: 10),
                              ColorResin(width: 50, color: theme.value.magenta),
                              const SizedBox(width: 10),
                              ColorResin(width: 15, color: theme.value.green),
                              const SizedBox(width: 10),
                              ColorResin(width: 50, color: theme.value.blue),
                            ],
                          ),
                          Row(
                            children: [
                              const SizedBox(width: 5),
                              ColorResin(
                                  width: 20, color: theme.value.brightCyan),
                              const SizedBox(width: 10),
                              ColorResin(width: 30, color: theme.value.cyan),
                              const SizedBox(width: 10),
                              ColorResin(
                                  width: 20, color: theme.value.brightGreen),
                              const SizedBox(width: 10),
                              ColorResin(width: 40, color: theme.value.red),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              theme.key,
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(color: theme.value.foreground),
            ),
          ],
        ),
        if (selected)
          Positioned.directional(
            textDirection: TextDirection.ltr,
            bottom: 30,
            end: 10,
            child: Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
      ],
    );
  }
}

class ColorResin extends StatelessWidget {
  final Color color;
  final double width;
  const ColorResin({super.key, this.width = 20, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: color,
      ),
      width: width,
    );
  }
}
