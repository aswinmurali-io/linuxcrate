import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:json_annotation/json_annotation.dart';

part 'ramdisk.g.dart';

@JsonSerializable(nullable: false)
class RamDisk {
  final String name;
  final int sizeInMegaBytes;
  final bool mounted;

  const RamDisk({
    @required this.name,
    @required this.sizeInMegaBytes,
    this.mounted: false,
  });

  factory RamDisk.fromJson(Map<String, dynamic> json) =>
      _$RamDiskFromJson(json);

  Map<String, dynamic> toJson() => _$RamDiskToJson(this);

  @override
  toString() =>
      'RamDisk(name: $name, size: $sizeInMegaBytes MB, mounted: $mounted)';
}

abstract class RamDiskManager {
  static const saveUrl = 'data/ramDisks.json';

  Future<String> create(
    List<RamDisk> ramDisks,
    RamDisk disk,
    BuildContext context,
  );

  Future<String> eject(
    List<RamDisk> ramDisks,
    RamDisk disk,
  );

  Future<String> mount(
    List<RamDisk> ramDisks,
    RamDisk disk,
  );

  Future<String> remove(
    List<RamDisk> ramDisks,
    RamDisk disk,
  );

  Future<List<RamDisk>> checkMounts(List<RamDisk> ramDisks);

  Future<List<RamDisk>> list();

  Future<void> open(RamDisk disk);

  Future<void> save(List<RamDisk> ramDisks) async {
    final file = File(saveUrl);

    await file.create(recursive: true);

    Map<String, dynamic> json = {};

    ramDisks.forEach((ramDisk) => json[ramDisk.name] = ramDisk.toJson());

    await file.writeAsString(jsonEncode(json));
  }

  static RamDiskManager get() {
    if (Platform.isLinux)
      return LinuxRamDiskManager();
    else
      return DummyPackageManager();
  }
}

class DummyPackageManager extends RamDiskManager {
  @override
  create(ramDisks, disk, context) async => '';

  @override
  eject(ramDisks, disk) async => '';

  @override
  list() async => [];

  @override
  remove(ramDisks, disk) async => '';

  @override
  open(disk) async => null;

  @override
  mount(ramDisks, disk) async => '';

  @override
  checkMounts(ramDisks) async => [];
}

class LinuxRamDiskManager extends RamDiskManager {
  @override
  create(ramDisks, disk, context) async {
    // pkexec mkdir -p /media/linuxcrate/diskname

    ProcessResult process;
    List<String> output = [];

    process = await Process.run('pkexec', [
      'mkdir',
      '-p',
      '/media/linuxcrate/${disk.name}',
    ]);

    output.addAll([process.stdout, process.stderr]);

    // sudo mount -t tmpfs -o size=1MB tmpfs /media/linuxcrate/diskname

    process = await Process.run('sudo', [
      'mount',
      '-t',
      'tmpfs',
      '-o',
      'size=${disk.sizeInMegaBytes}M',
      'tmpfs',
      '/media/linuxcrate/${disk.name}'
    ]);

    output.addAll([process.stdout, process.stderr]);

    disk = RamDisk(
      name: disk.name,
      sizeInMegaBytes: disk.sizeInMegaBytes,
      mounted: true,
    );

    ramDisks.add(disk);

    return output.join('\n');
  }

  @override
  eject(ramDisks, disk) async {
    // sudo umount /media/linuxcrate/diskname

    final process = await Process.run('pkexec', [
      'umount',
      '-l',
      '/media/linuxcrate/${disk.name}',
    ]);

    int index = ramDisks.indexOf(disk);

    ramDisks.remove(disk);

    disk = RamDisk(
      name: disk.name,
      sizeInMegaBytes: disk.sizeInMegaBytes,
      mounted: false,
    );

    ramDisks.insert(index, disk);

    await save(ramDisks);

    return '${process.stdout}\n${process.stderr}';
  }

  @override
  mount(ramDisks, disk) async {
    // sudo mount -t tmpfs -o size=1M tmpfs /media/linuxcrate/diskname

    final process = await Process.run('sudo', [
      'mount',
      '-t',
      'tmpfs',
      '-o',
      'size=${disk.sizeInMegaBytes}M',
      'tmpfs',
      '/media/linuxcrate/${disk.name}'
    ]);

    int index = ramDisks.indexOf(disk);

    ramDisks.remove(disk);

    disk = RamDisk(
      name: disk.name,
      sizeInMegaBytes: disk.sizeInMegaBytes,
      mounted: true,
    );

    ramDisks.insert(index, disk);

    await save(ramDisks);

    return '${process.stdout}\n${process.stderr}';
  }

  @override
  remove(ramDisks, disk) async {
    // sudo unmount /media/linuxcrate/diskname

    ProcessResult process;
    List<String> output = [];

    process = await Process.run('pkexec', [
      'umount',
      '-l',
      '/media/linuxcrate/${disk.name}',
    ]);

    output.addAll([process.stdout, process.stderr]);

    // sudo rm -r /media/linuxcrate/diskname

    process = await Process.run('pkexec', [
      'rm',
      '-rf',
      '/media/linuxcrate/${disk.name}',
    ]);

    output.addAll([process.stdout, process.stderr]);

    ramDisks.remove(disk);

    await save(ramDisks);

    return output.join('\n');
  }

  @override
  list() async {
    // loading only ram disk created by linuxcrate for safety.

    final file = File(RamDiskManager.saveUrl);

    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('{}');
    }

    String content = await file.readAsString();

    Map<String, dynamic> json = jsonDecode(content);

    List<RamDisk> ramDisks = [];

    json.forEach(
        (diskname, ramDiskJson) => ramDisks.add(RamDisk.fromJson(ramDiskJson)));

    return ramDisks;
  }

  @override
  checkMounts(ramDisks) async {
    // df /media/linuxcrate/diskname

    for (var disk in ramDisks) {
      final process =
          await Process.run('df', ['/media/linuxcrate/${disk.name}']);

      String output = process.stdout;

      // Filesystem     1K-blocks  Used Available Use% Mounted on
      // tmpfs               4096     0      4096   0% /media/linuxcrate/diskname

      String fs = output.split('\n').skip(1).first.split(' ').first;

      // if tmpfs then it's ram disk is mounted.

      if (fs == 'tmpfs') {
        int index = ramDisks.indexOf(disk);

        ramDisks.remove(disk);

        disk = RamDisk(
          name: disk.name,
          sizeInMegaBytes: disk.sizeInMegaBytes,
          mounted: true,
        );

        ramDisks.insert(index, disk);
      } else {
        int index = ramDisks.indexOf(disk);

        ramDisks.remove(disk);

        disk = RamDisk(
          name: disk.name,
          sizeInMegaBytes: disk.sizeInMegaBytes,
          mounted: false,
        );

        ramDisks.insert(index, disk);
      }
    }

    await save(ramDisks);

    return ramDisks;
  }

  @override
  open(disk) async =>
      await Process.start('xdg-open', ['/media/linuxcrate/${disk.name}']);
}

class RamDiskUI {
  final RamDiskManager ramDiskManager;

  const RamDiskUI(this.ramDiskManager);

  Future<void> askConfig(List<RamDisk> ramDisks, BuildContext context) async {
    String diskname;
    int sizeInMegaBytes;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("New RAM Disk"),
        content: Wrap(
          runSpacing: 5.0,
          children: [
            Text("Enter a name."),
            TextField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[A-Za-z]'),
                ),
              ],
              onChanged: (value) => diskname = value,
            ),
            Text("Enter the size."),
            TextField(
              decoration: const InputDecoration(
                suffixText: "MB",
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => sizeInMegaBytes = int.parse(value),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              if (diskname != null && sizeInMegaBytes != null) {
                final disk =
                    RamDisk(name: diskname, sizeInMegaBytes: sizeInMegaBytes);
                await ramDiskManager.create(ramDisks, disk, context);
              }
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.save),
            label: Text("Make"),
          ),
          ElevatedButton.icon(
            onPressed: Navigator.of(context).pop,
            icon: Icon(Icons.cancel),
            label: Text("Cancel"),
          ),
        ],
      ),
    );
  }
}
