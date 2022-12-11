import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wives/providers/preferences_provider.dart';
import 'package:xterm/ui.dart';
import 'package:wives/extensions/color.dart';
import 'package:wives/extensions/terminal_theme.dart';

final borderRadius = BorderRadius.circular(7);

class SchemeTilePainter extends CustomPainter {
  final TerminalTheme theme;

  SchemeTilePainter(this.theme);

  Color get tabColor => theme.background.isDark
      ? theme.background.lighten()
      : theme.background.darken();

  Color get tabbarColor => theme.background.isDark
      ? theme.background.darken()
      : theme.background.lighten();

  void drawIcon(
    Canvas canvas,
    IconData icon,
    Offset offset, {
    double? width,
    double? fontSize,
  }) {
    final builder = ParagraphBuilder(
      ParagraphStyle(
        fontFamily: icon.fontFamily,
        fontSize: fontSize ?? 6,
      ),
    )..addText(String.fromCharCode(icon.codePoint));
    final para = builder.build();
    para.layout(ParagraphConstraints(width: width ?? 60));
    canvas.drawParagraph(para, offset);
  }

  void drawPill(
    Canvas canvas,
    double titleBarHeight,
    Color color, {
    double leftFactor = 1,
    double widthFactor = 1,
    int row = 1,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          20 * leftFactor,
          titleBarHeight * row + 10,
          20 * widthFactor,
          10,
        ),
        const Radius.circular(5),
      ),
      Paint()..color = color,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            const Radius.circular(5),
          ),
        ),
      Colors.black,
      5,
      false,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
        const Radius.circular(5),
      ),
      Paint()..color = theme.background,
    );

    final titleBarHeight = size.height / 6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, titleBarHeight),
        const Radius.circular(5),
      ),
      Paint()..color = tabbarColor,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5, 5, size.width / 6, size.height / 12),
        const Radius.circular(2),
      ),
      Paint()..color = tabColor,
    );

    drawIcon(canvas, Icons.close, Offset(size.width / 7, 7));

    canvas.drawCircle(
      Offset(size.width - 10, 10),
      4,
      Paint()..color = tabColor,
    );
    drawIcon(
      canvas,
      Icons.close,
      Offset(size.width - 12.3, size.height / 14),
      fontSize: 5,
    );

    canvas.drawCircle(
      Offset(size.width - 20, 10),
      4,
      Paint()..color = tabColor,
    );
    drawIcon(
      canvas,
      Icons.check_box_outline_blank_rounded,
      Offset(size.width - 22, size.height / 14),
      fontSize: 4,
    );

    canvas.drawCircle(
      Offset(size.width - 30, 10),
      4,
      Paint()..color = tabColor,
    );
    drawIcon(
      canvas,
      Icons.minimize_outlined,
      Offset(size.width - 32, size.height / 14),
      fontSize: 4,
    );

    drawPill(canvas, titleBarHeight, theme.blue, leftFactor: .4);
    drawPill(
      canvas,
      titleBarHeight,
      theme.brightMagenta,
      leftFactor: 1.7,
      widthFactor: 2,
    );
    drawPill(
      canvas,
      titleBarHeight,
      theme.white,
      leftFactor: 4.3,
      widthFactor: 1.5,
    );
    drawPill(canvas, titleBarHeight, theme.red, leftFactor: 6.4);
    drawPill(
      canvas,
      titleBarHeight,
      theme.red,
      leftFactor: 1,
      row: 2,
      widthFactor: 2,
    );
    drawPill(canvas, titleBarHeight, theme.white, leftFactor: 3.5, row: 2);
    drawPill(
      canvas,
      titleBarHeight,
      theme.white,
      leftFactor: 5,
      widthFactor: .7,
      row: 2,
    );
    drawPill(
      canvas,
      titleBarHeight,
      theme.yellow,
      leftFactor: 6.2,
      widthFactor: 1.8,
      row: 2,
    );

    drawPill(
      canvas,
      titleBarHeight,
      theme.brightBlack,
      leftFactor: .5,
      row: 3,
      widthFactor: .8,
    );
    drawPill(
      canvas,
      titleBarHeight,
      theme.magenta,
      leftFactor: 1.7,
      row: 3,
      widthFactor: 2.4,
    );
    drawPill(
      canvas,
      titleBarHeight,
      theme.green,
      leftFactor: 4.5,
      widthFactor: .7,
      row: 3,
    );
    drawPill(
      canvas,
      titleBarHeight,
      theme.blue,
      leftFactor: 5.5,
      widthFactor: 2.8,
      row: 3,
    );

    drawPill(
      canvas,
      titleBarHeight,
      theme.cyan,
      leftFactor: .8,
      row: 4,
      widthFactor: .9,
    );
    drawPill(
      canvas,
      titleBarHeight,
      theme.brightCyan,
      leftFactor: 2,
      row: 4,
      widthFactor: 1.6,
    );
    drawPill(
      canvas,
      titleBarHeight,
      theme.green,
      leftFactor: 4,
      widthFactor: 1.2,
      row: 4,
    );
    drawPill(
      canvas,
      titleBarHeight,
      theme.brightRed,
      leftFactor: 5.5,
      widthFactor: 2.4,
      row: 4,
    );
  }

  @override
  bool shouldRepaint(covariant SchemeTilePainter oldDelegate) {
    return !oldDelegate.theme.equal(theme);
  }
}

class SchemeTile extends HookConsumerWidget {
  final MapEntry<String, TerminalTheme> theme;
  final Brightness brightness;
  final Color foreground;
  const SchemeTile({
    required this.theme,
    required this.brightness,
    required this.foreground,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final selected = ref.watch(
        preferencesProvider.select((s) => s.defaultTheme.key == theme.key));

    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: borderRadius,
              onTap: () {
                ref.read(preferencesProvider).setDefaultTheme(theme);
                ref.read(preferencesProvider).setThemeMode(
                      brightness == Brightness.dark
                          ? ThemeMode.dark
                          : ThemeMode.light,
                    );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: selected
                      ? Border.all(
                          color: theme.value.blue,
                          width: 2,
                        )
                      : null,
                  borderRadius: borderRadius,
                ),
                child: CustomPaint(
                  isComplex: true,
                  size: const Size(180, 115),
                  painter: SchemeTilePainter(theme.value),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              theme.key,
              style: DefaultTextStyle.of(context).style.copyWith(
                    color: foreground,
                  ),
            ),
          ],
        ),
        if (selected)
          Positioned.directional(
            textDirection: TextDirection.ltr,
            bottom: 30,
            end: 10,
            child: Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
      ],
    );
  }
}
