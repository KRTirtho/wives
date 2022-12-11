import 'package:flutter/material.dart';

class CompactIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const CompactIconButton({
    required this.child,
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 20,
      minWidth: 20,
      elevation: 0,
      padding: const EdgeInsets.all(2),
      textColor: Theme.of(context).iconTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
