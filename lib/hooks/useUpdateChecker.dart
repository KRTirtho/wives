import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:url_launcher/url_launcher_string.dart';
import 'package:version/version.dart';
import 'package:wives/components/anchor_button.dart';
import 'package:wives/hooks/usePackageInfo.dart';
import 'package:wives/providers/preferences_provider.dart';

void useUpdateChecker(WidgetRef ref) {
  final isCheckUpdateEnabled =
      ref.watch(preferencesProvider.select((s) => s.checkUpdate));
  final packageInfo = usePackageInfo(
    appName: 'Wives',
    packageName: 'wives',
  );
  final Future<List<Version?>> Function() checkUpdate = useCallback(
    () async {
      final value = await http.get(
        Uri.parse(
            "https://api.github.com/repos/KRTirtho/wives/releases/latest"),
      );
      final tagName =
          (jsonDecode(value.body)["tag_name"] as String).replaceAll("v", "");
      final currentVersion = packageInfo.version == "Unknown"
          ? null
          : Version.parse(
              packageInfo.version,
            );
      final latestVersion = Version.parse(tagName);
      return [currentVersion, latestVersion];
    },
    [packageInfo.version],
  );

  final context = useContext();

  download(String url) => launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );

  useEffect(() {
    if (isCheckUpdateEnabled != true) return null;
    checkUpdate().then((value) {
      final currentVersion = value.first;
      final latestVersion = value.last;
      if (currentVersion == null ||
          latestVersion == null ||
          (latestVersion.isPreRelease && !currentVersion.isPreRelease) ||
          (!latestVersion.isPreRelease && currentVersion.isPreRelease)) return;
      if (latestVersion <= currentVersion) return;
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black26,
        builder: (context) {
          const url = "https://github.com/KRTirtho/wives/releases/latest";
          return AlertDialog(
            title: const Text("Wives has an update"),
            actions: [
              ElevatedButton(
                child: const Text("Marry again (Download)"),
                onPressed: () => download(url),
              ),
            ],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Wives v${value.last} has been released"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Read the latest "),
                    AnchorButton(
                      "release notes",
                      style: const TextStyle(color: Colors.blue),
                      onTap: () => launchUrlString(
                        url,
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
    return null;
  }, [packageInfo, isCheckUpdateEnabled]);
}
