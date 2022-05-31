/*
Copyright 2021 The dahliaOS Authors
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
import 'package:terminal/views/terminal_frame.dart';
import 'package:terminal/views/terminal_settings.dart';
import 'package:zenit_ui/zenit_ui.dart';

void main() {
  runApp(const Terminal());
}

class Terminal extends StatelessWidget {
  const Terminal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //setWindowTitle("Terminal");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Terminal',
      initialRoute: '/',
      theme: ThemeEngine.zenitDefaultLightTheme,
      darkTheme: ThemeEngine.zenitDefaultDarkTheme,
      themeMode: ThemeMode.dark,
      routes: {
        "/": (context) => const TerminalFrame(),
        "/settings": (context) => const TerminalSettings(),
      },
    );
  }
}
