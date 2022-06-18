import 'dart:io';

class NativeUtils {
  static List<String> getShells() {
    if (Platform.isWindows) {
      return [
        "powershell",
        "cmd",
      ];
    }
    final process = Process.runSync("chsh", ["-l"]);
    final shells = (process.stdout as String)
        .split("\n")
        .map((shell) => shell.split("/").last)
        .where((shell) => shell.isNotEmpty)
        .toSet();

    shells.remove("git-shell");
    return List.castFrom<dynamic, String>(shells.toList());
  }
}
