/// Contains backend logic to list, install, uninstall packages in the system.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'content.dart';

class Package {
  final String name;
  final String description;
  final String version;

  const Package({this.name, this.description, this.version});
}

abstract class PackageManager {
  get sudoAgent;
  get packageManager;
  get packageRemove;
  get packageUpgrade;
  get listPackage;

  Future<List<Package>> get getLocalPackages;
  Future<List<Package>> searchLocalPackages(String keyword);
  Future<String> updateLocalPackages(String packageName, BuildContext context);
  Future<String> removeLocalPackages(String packageName, BuildContext context);
  Future<List<String>> searchGlobalPackages(String _searchKeyword);
  Future<String> installGlobalPackage(String packageName, BuildContext context);

  Future<String> _exec(List<String> args, BuildContext context,
      {bool sudo: false}) async {
    Process process;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Executing in background...')));
    if (sudo)
      process = await Process.start(sudoAgent, [packageManager, ...args]);
    else
      process = await Process.start(packageManager, [...args]);
    stdoutTextWidget = '';
    await process.stdout.transform(utf8.decoder).forEach((stdout) =>
        setStateFromContent?.call(() => stdoutTextWidget += stdout));
    await process.stderr.transform(utf8.decoder).forEach((stderr) =>
        setStateFromContent?.call(() => stdoutTextWidget += stderr));

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Execution complete!')));
    return stdoutTextWidget;
  }

  static PackageManager getPackageManager() {
    if (Platform.isLinux)
      return AptPackageManager();
    else
      return DummyPackageManager();
  }
}

class DummyPackageManager extends PackageManager {
  @override
  String get sudoAgent => '';

  @override
  String get packageManager => '';

  @override
  String get packageRemove => '';

  @override
  String get packageUpgrade => '';

  @override
  String get listPackage => '';

  /// Get a list of locally installed system packages.
  @override
  Future<List<Package>> get getLocalPackages async => <Package>[];

  @override
  Future<List<Package>> searchLocalPackages(String keyword) async =>
      <Package>[];

  @override
  Future<String> updateLocalPackages(
          String packageName, BuildContext context) async =>
      '';

  @override
  Future<String> removeLocalPackages(
          String packageName, BuildContext context) async =>
      '';

  @override
  Future<List<String>> searchGlobalPackages(String _searchKeyword) async {}

  @override
  Future<String> installGlobalPackage(
          String packageName, BuildContext context) async =>
      '';
}

class AptPackageManager extends PackageManager {
  @override
  String get sudoAgent => 'pkexec';

  @override
  String get packageManager => 'snap';

  @override
  String get packageRemove => 'remove';

  @override
  List<String> get packageUpgrade => ['refresh'];

  @override
  List<String> get listPackage => ['list'];

  /// Get a list of locally installed system packages.
  @override
  Future<List<Package>> get getLocalPackages async {
    List<Package> packages = [];
    final process = await Process.start(packageManager, listPackage);
    await process.stdout.transform(utf8.decoder).forEach((stdout) {
      final depInfoLines = stdout.split('\n').skip(1);
      depInfoLines.forEach((depInfoLine) {
        try {
          final depInfo = depInfoLine.split(' ');
          packages.add(Package(
            name: depInfo[0],
            description: depInfo[4],
            version: depInfo[1],
          ));
        } on RangeError catch (error) {
          print(error);
        }
      });
    });
    return packages;
  }

  @override
  Future<List<Package>> searchLocalPackages(String keyword) async {
    if (keyword.isEmpty) return await getLocalPackages;
    List<Package> filteredPackages = [];
    final packages = await getLocalPackages;
    final regex = RegExp(keyword);
    packages.forEach((package) {
      if (regex.hasMatch(package.name)) filteredPackages.add(package);
    });
    return filteredPackages;
  }

  @override
  Future<String> updateLocalPackages(
          String packageName, BuildContext context) async =>
      await _exec([...packageUpgrade, packageName], context, sudo: true);

  @override
  Future<String> removeLocalPackages(
      String packageName, BuildContext context) async {
    return await _exec([packageRemove, packageName], context, sudo: true);
  }

  @override
  Future<String> installGlobalPackage(
          String packageName, BuildContext context) async =>
      await _exec(['install', packageName], context, sudo: true);

  @override
  Future<List<String>> searchGlobalPackages(String _searchKeyword) async {
    if (_searchKeyword.isNotEmpty) {
      final process =
          await Process.run(packageManager, ['search', _searchKeyword]);
      String stdout = await process.stdout;
      return stdout.split('\n').skip(1).toList();
    }
    return [];
  }
}
