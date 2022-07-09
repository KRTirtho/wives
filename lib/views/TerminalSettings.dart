import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/components/WindowTitleBar.dart';
import 'package:wives/providers/PreferencesProvider.dart';

class TerminalSettings extends ConsumerWidget {
  const TerminalSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final preferences = ref.watch(preferencesProvider);
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
        ],
      ),
    );
  }
}
