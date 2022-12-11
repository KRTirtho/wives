import 'package:flutter/material.dart';

class CustomTile extends StatelessWidget {
  final Widget? title;
  final Widget? leading;
  final Widget? trailing;
  final double? titleGap;

  const CustomTile({
    this.leading,
    this.title,
    this.trailing,
    this.titleGap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ListTileTheme.of(context);

    return Container(
      padding:
          theme.contentPadding ?? const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: theme.tileColor,
        borderRadius: (theme.shape as RoundedRectangleBorder?)?.borderRadius ??
            BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (leading != null) leading!,
          if (titleGap != null && leading != null)
            SizedBox(
              width: titleGap,
            ),
          if (title != null) title!,
          if (titleGap != null && trailing != null)
            SizedBox(
              width: titleGap,
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
