import 'dart:io';

class NativeUtils {
  static List<String> getShells() {
    if (Platform.isWindows) {
      return [
        "cmd.exe",
        if (File("C:/Program Files/PowerShell/7/pwsh.exe").existsSync())
          "pwsh.exe",
        "powershell.exe",
      ];
    }
    final shells = File("/etc/shells")
        .readAsStringSync()
        .split("\n")
        .map((shell) => shell.split("/").last)
        .where((shell) => shell.isNotEmpty)
        .toSet();

    shells.remove("git-shell");
    return List.castFrom<dynamic, String>(shells.toList());
  }
}
