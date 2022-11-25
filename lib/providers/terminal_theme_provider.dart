import 'package:dio/dio.dart';
import 'package:flutter/animation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:xterm/ui.dart';

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

extension TerminalThemeJson on TerminalTheme {
  static TerminalTheme fromJson(Map<String, dynamic> json) {
    return TerminalTheme(
      searchHitBackground: TerminalThemes.defaultTheme.searchHitBackground,
      searchHitForeground: TerminalThemes.defaultTheme.searchHitForeground,
      searchHitBackgroundCurrent:
          TerminalThemes.defaultTheme.searchHitBackgroundCurrent,
      black: json["black"] != null
          ? HexColor.fromHex(json["black"])
          : TerminalThemes.defaultTheme.black,
      red: json["red"] != null
          ? HexColor.fromHex(json["red"])
          : TerminalThemes.defaultTheme.red,
      green: json["green"] != null
          ? HexColor.fromHex(json["green"])
          : TerminalThemes.defaultTheme.green,
      yellow: json["yellow"] != null
          ? HexColor.fromHex(json["yellow"])
          : TerminalThemes.defaultTheme.yellow,
      blue: json["blue"] != null
          ? HexColor.fromHex(json["blue"])
          : TerminalThemes.defaultTheme.blue,
      magenta: json["purple"] != null
          ? HexColor.fromHex(json["purple"])
          : TerminalThemes.defaultTheme.magenta,
      cyan: json["cyan"] != null
          ? HexColor.fromHex(json["cyan"])
          : TerminalThemes.defaultTheme.cyan,
      white: json["white"] != null
          ? HexColor.fromHex(json["white"])
          : TerminalThemes.defaultTheme.white,
      brightBlack: json["brightBlack"] != null
          ? HexColor.fromHex(json["brightBlack"])
          : TerminalThemes.defaultTheme.brightBlack,
      brightRed: json["brightRed"] != null
          ? HexColor.fromHex(json["brightRed"])
          : TerminalThemes.defaultTheme.brightRed,
      brightGreen: json["brightGreen"] != null
          ? HexColor.fromHex(json["brightGreen"])
          : TerminalThemes.defaultTheme.brightGreen,
      brightYellow: json["brightYellow"] != null
          ? HexColor.fromHex(json["brightYellow"])
          : TerminalThemes.defaultTheme.brightYellow,
      brightBlue: json["brightBlue"] != null
          ? HexColor.fromHex(json["brightBlue"])
          : TerminalThemes.defaultTheme.brightBlue,
      brightMagenta: json["brightPurple"] != null
          ? HexColor.fromHex(json["brightPurple"])
          : TerminalThemes.defaultTheme.brightMagenta,
      brightCyan: json["brightCyan"] != null
          ? HexColor.fromHex(json["brightCyan"])
          : TerminalThemes.defaultTheme.brightCyan,
      brightWhite: json["brightWhite"] != null
          ? HexColor.fromHex(json["brightWhite"])
          : TerminalThemes.defaultTheme.brightWhite,
      background: json["background"] != null
          ? HexColor.fromHex(json["background"])
          : TerminalThemes.defaultTheme.background,
      foreground: json["foreground"] != null
          ? HexColor.fromHex(json["foreground"])
          : TerminalThemes.defaultTheme.foreground,
      cursor: json["cursorColor"] != null
          ? HexColor.fromHex(json["cursorColor"])
          : TerminalThemes.defaultTheme.cursor,
      selection: json["selectionBackground"] != null
          ? HexColor.fromHex(json["selectionBackground"])
          : TerminalThemes.defaultTheme.selection,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "cursor": cursor.toHex(),
      "selection": selection.toHex(),
      "foreground": foreground.toHex(),
      "background": background.toHex(),
      "black": black.toHex(),
      "white": white.toHex(),
      "red": red.toHex(),
      "green": green.toHex(),
      "yellow": yellow.toHex(),
      "blue": blue.toHex(),
      "magenta": magenta.toHex(),
      "cyan": cyan.toHex(),
      "brightBlack": brightBlack.toHex(),
      "brightRed": brightRed.toHex(),
      "brightGreen": brightGreen.toHex(),
      "brightYellow": brightYellow.toHex(),
      "brightBlue": brightBlue.toHex(),
      "brightMagenta": brightMagenta.toHex(),
      "brightCyan": brightCyan.toHex(),
      "brightWhite": brightWhite.toHex(),
      "searchHitBackground": searchHitBackground.toHex(),
      "searchHitBackgroundCurrent": searchHitBackgroundCurrent.toHex(),
      "searchHitForeground": searchHitForeground.toHex(),
    };
  }
}

const url =
    "https://2zrysvpla9.execute-api.eu-west-2.amazonaws.com/prod/themes";

final themesProvider = FutureProvider<Map<String, TerminalTheme>>(
  (ref) async {
    final dio = Dio(BaseOptions(responseType: ResponseType.json));

    final res = await dio.get<List>(url);

    final themes = Map<String, TerminalTheme>.fromEntries(
      res.data?.map((json) {
            return MapEntry(
              json["name"],
              TerminalThemeJson.fromJson(json),
            );
          }) ??
          [],
    );
    return {
      "Default": TerminalThemes.defaultTheme,
      "White On Black": TerminalThemes.whiteOnBlack,
      ...themes
    };
  },
);
