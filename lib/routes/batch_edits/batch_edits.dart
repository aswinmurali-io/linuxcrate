import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

import 'package:path/path.dart';

class DesktopManager {
  static Future<void> batchCopy(
      String src, String des, BuildContext context) async {
    final files = Glob(src);

    for (FileSystemEntity entity in files.listSync()) {
      final filename = basename(entity.path);
      print('$des/$filename');
      try {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Executing...'),
          duration: const Duration(seconds: 1),
        ));
        try {
          await File(entity.path).copy('$des/$filename');
        } catch (e) {
          await Process.run('cp', ['-r', '-f', src, des]);
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Finished'),
          duration: const Duration(seconds: 1),
        ));
      } on FileSystemException {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed'),
          duration: const Duration(seconds: 1),
        ));
      }
    }
  }

  static Future<void> batchMove(
      String src, String des, BuildContext context) async {
    final files = Glob(src);

    for (FileSystemEntity entity in files.listSync()) {
      final filename = basename(entity.path);
      print('$des/$filename');
      try {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Executing...'),
          duration: const Duration(seconds: 1),
        ));
        try {
          await File(entity.path).rename('$des/$filename');
        } catch (e) {
          await Process.run('mv', ['-f', src, des]);
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Finished'),
          duration: const Duration(seconds: 1),
        ));
      } on FileSystemException {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed'),
          duration: const Duration(seconds: 1),
        ));
      }
    }
  }

  static Future<void> batchExt(
      String src, String des, BuildContext context) async {
    final files = Glob(src);

    for (FileSystemEntity entity in files.listSync()) {
      final filename = basename(entity.path);
      final 
      print('$des/${filename.split('.').first}');
      try {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Executing...'),
          duration: const Duration(seconds: 1),
        ));
        try {
          await File(entity.path).rename('$des/$filename');
        } catch (e) {
          await Process.run('mv', ['-f', src, des]);
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Finished'),
          duration: const Duration(seconds: 1),
        ));
      } on FileSystemException {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed'),
          duration: const Duration(seconds: 1),
        ));
      }
    }
  }

  static Future<void> batchDelete(String src, BuildContext context) async {
    final files = Glob(src);

    try {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Executing...'),
        duration: const Duration(seconds: 1),
      ));
      for (FileSystemEntity entity in files.listSync()) {
        print(entity.path);
        await File(entity.path).delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Finished'),
        duration: const Duration(seconds: 1),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed'),
        duration: const Duration(seconds: 1),
      ));
    }
  }

  
}
