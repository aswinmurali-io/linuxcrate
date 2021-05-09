import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:json_annotation/json_annotation.dart';

part 'ramdisk.g.dart';

@JsonSerializable()
class RamDisk {
  final String name;
  final int sizeInMegaBytes;

  const RamDisk({this.name, this.sizeInMegaBytes});

  factory RamDisk.fromJson(Map<String, dynamic> json) =>
      _$RamDiskFromJson(json);

  Map<String, dynamic> toJson() => _$RamDiskToJson(this);
}

abstract class RamDiskManager {
  static const saveUrl = 'data/ramDisks.json';

  Future<String> create(RamDisk disk, BuildContext context);

  Future<String> eject(RamDisk disk);

  Future<String> remove(RamDisk disk);

  Future<List<RamDisk>> list();

  Future<void> save(List<RamDisk> ramDisks) async {
    final file = File(saveUrl);

    await file.create(recursive: true);

    Map<String, dynamic> json = {};

    ramDisks.forEach((ramDisk) => json[ramDisk.name] = ramDisk.toJson());

    await file.writeAsString(jsonEncode(json));
  }

  static RamDiskManager getRamDiskManager() {
    if (Platform.isLinux)
      return LinuxRamDiskManager();
    else
      return DummyPackageManager();
  }
}

class DummyPackageManager extends RamDiskManager {
  @override
  create(disk, context) async => '';

  @override
  eject(disk) async => '';

  @override
  list() async => [];

  @override
  remove(disk) async => '';
}

class LinuxRamDiskManager extends RamDiskManager {
  @override
  create(disk, context) async {
    Process process;
    String stdoutTextWidget;

    process = await Process.start('pkexec', [
      'mkdir',
      '-p',
      '/media/linuxcrate/${disk.name}',
    ]);

    await process.stdout
        .transform(utf8.decoder)
        .forEach((stdout) => stdoutTextWidget += stdout);
    await process.stderr
        .transform(utf8.decoder)
        .forEach((stderr) => stdoutTextWidget += stderr);

    process = await Process.start('sudo', [
      'mount',
      '-t',
      'tmpfs',
      '-o',
      'size=${disk.sizeInMegaBytes}\M',
      'tmpfs',
      '/media/linuxcrate/${disk.name}'
    ]);

    await process.stdout
        .transform(utf8.decoder)
        .forEach((stdout) => stdoutTextWidget += stdout);
    await process.stderr
        .transform(utf8.decoder)
        .forEach((stderr) => stdoutTextWidget += stderr);

    return stdoutTextWidget;
  }

  @override
  eject(disk) async {
    // sudo unmount /media/linuxcrate/diskname

    final process = await Process.run('pkexec', [
      'umount',
      '/media/linuxcrate/${disk.name}',
    ]);

    return process.stdout;
  }

  @override
  remove(disk) async {
    // sudo unmount /media/linuxcrate/diskname

    await Process.run('pkexec', [
      'umount',
      '/media/linuxcrate/${disk.name}',
    ]);

    // sudo rm -r /media/linuxcrate/diskname

    final process = await Process.run('pkexec', [
      'rm',
      '-rf',
      '/media/linuxcrate/${disk.name}',
    ]);

    return process.stdout;
  }

  @override
  list() async {
    // ls -lh /media/linuxcrate/

    final process = await Process.run('ls', [
      '-lh',
      '/media/linuxcrate/',
    ]);

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

    // split each line and take the last part. Also compare it with the
    // app's own ram disk record and list only the once that are currently
    // available. If found get the [sizeInMegaBytes] for that [ramDisk].

    final ramDiskNamesFromDisk = '${process.stdout}'.split('\n').map((line) {
      final name = line.split(' ').last;
      int sizeInMegaBytes;
      try {
        sizeInMegaBytes =
            ramDisks.where((disk) => disk.name == name).first.sizeInMegaBytes;
      } on StateError {
        sizeInMegaBytes = 0;
      }
      return RamDisk(name: name, sizeInMegaBytes: sizeInMegaBytes);
    }).toList();

    // removing the first and last parts because they are not required.
    // ls outputs unnecessary parts in stdout.

    return ramDiskNamesFromDisk.sublist(1, ramDiskNamesFromDisk.length - 1);
  }
}

class RamDiskUI {
  final RamDiskManager ramDiskManager;

  const RamDiskUI(this.ramDiskManager);

  Future<void> askConfig(BuildContext context) async {
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
              if (diskname != null && sizeInMegaBytes != null)
                await ramDiskManager.create(
                    RamDisk(name: diskname, sizeInMegaBytes: sizeInMegaBytes),
                    context);
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
