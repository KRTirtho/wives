import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wives/views/terminal_frame.dart';
import 'package:wives/views/terminal_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setTitle("Terminal");
    await windowManager.show();
    await windowManager.focus();
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
        scaffoldBackgroundColor: Colors.black,
      ),
      themeMode: ThemeMode.dark,
      routes: {
        "/": (context) => const TerminalFrame(),
        "/settings": (context) => const TerminalSettings(),
      },
    );
  }
}
