/// Contains backend logic to list, install, uninstall packages in the system.

import 'dart:convert';
import 'dart:io';

class Package {
  final String name;
  final String description;
  final String version;

  const Package({
    this.name,
    this.description,
    this.version,
  });

  /// Get a list of locally installed system packages.
  static Future<List<Package>> getLocalPackages() async {
    List<Package> packages = [
      Package(name: "Test", description: "test", version: "test"),
    ];
    // apt list --installed
    final process = await Process.start('apt', ['list', '--installed']);
    // <package name>/focal,now 1:13.99.1-1ubuntu3 <arch> [installed,upgradable to: 1:13.99.1-1ubuntu3.10]
    // pulseaudio-utils/focal,now 1:13.99.1-1ubuntu3 amd64 [installed,upgradable to: 1:13.99.1-1ubuntu3.10]
    await process.stdout.transform(utf8.decoder).forEach((stdoutLine) {
      final depInfo = stdoutLine.split('/');
      print(depInfo);
      // packages.add(Package(name: depInfo[0], description: depInfo[1]));
    });
    return packages;
  }
}
