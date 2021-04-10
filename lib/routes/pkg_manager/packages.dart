/// Contains backend logic to list, install, uninstall packages in the system.

import 'dart:convert';
import 'dart:io';

mixin ToAlias {}

class _TerminalOutput<T> {
  T output;
  _TerminalOutput(this.output);
}

class TerminalOutput = _TerminalOutput<String> with ToAlias;

class Package {
  final String name;
  final String description;
  final String version;

  const Package({
    this.name,
    this.description,
    this.version,
  });

  static const packageManager = 'apt';

  static const packageRemove = 'purge';

  static const packageAutoRemove = 'autoremove';

  static const packageUpgrade = ['install', '--only-upgrade'];

  static const listPackage = ['list', '--installed'];

  static const autoRemovePackages = 'autoremove';

  static Future<String> _exec(List<String> args) async {
    String output = '';
    final process = await Process.start('sudo', [packageManager, ...args], runInShell: true);
    await process.stdout.transform(utf8.decoder).forEach((stdout) => output += stdout);
    print('rr$output');
    return output;
  }

  /// Get a list of locally installed system packages.
  static Future<List<Package>> get getLocalPackages async {
    List<Package> packages = [];
    final process = await Process.start(packageManager, listPackage);
    await process.stdout.transform(utf8.decoder).forEach((stdout) {
      final depInfoLines = stdout.split('\n');
      depInfoLines.forEach((depInfoLine) {
        try {
          final depInfo = depInfoLine.split('/');
          packages.add(Package(
            name: depInfo[0],
            description: depInfo[1],
            version: "",
          ));
        } on RangeError catch (error) {
          print(error);
        }
      });
    });
    return packages;
  }

  static Future<List<Package>> searchLocalPackages(String keyword) async {
    if (keyword.isEmpty) return await getLocalPackages;
    List<Package> filteredPackages = [];
    final packages = await getLocalPackages;
    final regex = RegExp(keyword);
    packages.forEach((package) {
      if (regex.hasMatch(package.name)) filteredPackages.add(package);
    });
    return filteredPackages;
  }

  static Future<String> updateLocalPackages(String packageName) async =>
      await _exec([...packageUpgrade, packageName, '-y']);

  static Future<String> removeLocalPackages(String packageName) async =>
      await _exec([packageRemove, packageName, '-y']);

  static Future<String> get autoRemoveLocalPackages async =>
      await _exec([packageAutoRemove, '-y']);
}
