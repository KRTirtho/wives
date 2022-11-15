import 'package:flutter/material.dart';

class KeyboardKeyWidget extends StatelessWidget {
  final String keyboardKey;
  const KeyboardKeyWidget({required this.keyboardKey, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(3),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
      padding: const EdgeInsets.all(5),
      child: Text(
        keyboardKey,
        style: Theme.of(context).textTheme.caption,
      ),
    );
  }
}
