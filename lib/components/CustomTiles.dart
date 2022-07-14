import 'package:flutter/widgets.dart';

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
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
