import 'package:flutter/material.dart';

class TerminalSettings extends StatelessWidget {
  const TerminalSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(brightness: Brightness.dark),
      child: Scaffold(
        appBar: AppBar(),
      ),
    );
  }
}
