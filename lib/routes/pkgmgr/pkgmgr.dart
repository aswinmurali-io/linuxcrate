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
  get packageAutoRemove;
  get packageUpgrade;
  get listPackage;
  get autoRemovePackages;

  Future<List<Package>> get getLocalPackages;
  Future<List<Package>> searchLocalPackages(String keyword);
  Future<String> updateLocalPackages(String packageName, BuildContext context);
  Future<String> removeLocalPackages(String packageName, BuildContext context);
  Future<String> get autoRemoveLocalPackages;
  Stream<String> searchGlobalPackages(String _searchKeyword);
  Future<String> installGlobalPackage(String packageName, BuildContext context);

  Future<String> _exec(List<String> args, BuildContext context,
      {bool sudo: false, bool confirmYes: false}) async {
    Process process;
    if (sudo)
      process = await Process.start(
          sudoAgent, [packageManager, ...args, confirmYes ? '-y' : '']);
    else
      process = await Process.start(
          packageManager, [...args, confirmYes ? '-y' : '']);
    stdoutTextWidget = '';
    await process.stdout.transform(utf8.decoder).forEach((stdout) =>
        setStateFromContent?.call(() => stdoutTextWidget += stdout));
    await process.stderr.transform(utf8.decoder).forEach((stderr) =>
        setStateFromContent?.call(() => stdoutTextWidget += stderr));
    // WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
    if (stdoutTextWidget.split('\n').contains(
            "WARNING: apt does not have a stable CLI interface. Use with caution in scripts.") &&
        context != null)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Done!')));
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
  String get packageAutoRemove => '';

  @override
  String get packageUpgrade => '';

  @override
  String get listPackage => '';

  @override
  String get autoRemovePackages => '';

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
  Future<String> get autoRemoveLocalPackages async => '';

  @override
  Stream<String> searchGlobalPackages(String _searchKeyword) async* {}

  @override
  Future<String> installGlobalPackage(
          String packageName, BuildContext context) async =>
      '';
}

class AptPackageManager extends PackageManager {
  @override
  String get sudoAgent => 'pkexec';

  @override
  String get packageManager => 'apt';

  @override
  String get packageRemove => 'purge';

  @override
  String get packageAutoRemove => 'autoremove';

  @override
  List<String> get packageUpgrade => ['install', '--only-upgrade'];

  @override
  List<String> get listPackage => ['list', '--installed'];

  @override
  String get autoRemovePackages => 'autoremove';

  /// Get a list of locally installed system packages.
  @override
  Future<List<Package>> get getLocalPackages async {
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
      await _exec([...packageUpgrade, packageName], context,
          sudo: true, confirmYes: true);

  @override
  Future<String> removeLocalPackages(
          String packageName, BuildContext context) async =>
      await _exec([packageRemove, packageName], context,
          sudo: true, confirmYes: true);

  @override
  Future<String> installGlobalPackage(
          String packageName, BuildContext context) async =>
      await _exec(['install', packageName], context,
          sudo: true, confirmYes: true);

  @override
  Future<String> get autoRemoveLocalPackages async =>
      await _exec([packageAutoRemove], null, sudo: true, confirmYes: true);

  @override
  Stream<String> searchGlobalPackages(String _searchKeyword) async* {
    if (_searchKeyword.isNotEmpty) {
      final process =
          await Process.start('apt-cache', ['search', _searchKeyword]);
      // Notifying the stream builder
      yield* LineSplitter().bind(process.stdout.transform(utf8.decoder));
    }
  }
}
