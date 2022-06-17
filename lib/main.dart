import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:wives/views/terminal_frame.dart';
import 'package:wives/views/terminal_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  doWhenWindowReady(() {
    const initialSize = Size(700, 500);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
  runApp(const Terminal());
}

class Terminal extends StatelessWidget {
  const Terminal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Terminal',
      initialRoute: '/',
      darkTheme: ThemeData.dark().copyWith(
        backgroundColor: Colors.black,
        scaffoldBackgroundColor: Colors.transparent,
        buttonTheme: ButtonThemeData(
          hoverColor: Colors.grey.withOpacity(0.2),
        ),
      ),
      themeMode: ThemeMode.dark,
      routes: {
        "/": (context) => const TerminalFrame(),
        "/settings": (context) => const TerminalSettings(),
      },
    );
  }
}
