import 'package:flutter/material.dart';

class CompactIconButton extends MaterialButton {
  CompactIconButton({
    super.key,
    required super.onPressed,
    super.child,
  }) : super(
          height: 20,
          minWidth: 20,
          color: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.all(2),
          hoverColor: Colors.grey.withOpacity(.2),
        );
}
