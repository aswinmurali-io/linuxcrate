import 'dart:convert';
import 'dart:io';

import 'content.dart';

class PreConfig {
  static final url = 'lib/utils/preconfig/packs.json';
  static final preconfigScriptPath = 'lib/utils/preconfig';

  static Future<Map<String, dynamic>> loadPacks() async =>
      jsonDecode(await File(url).readAsString());

  static Future<void> installPack(Map<String, dynamic> pack) async {
    Process process;
    for (String bashScriptName in pack['content']) {
      process = await Process.start('pkexec', [
        'bash',
        '${Directory.current.path}/$preconfigScriptPath/$bashScriptName'
      ]);
      await process.stdout.transform(utf8.decoder).forEach((stdout) =>
          setStateFromContent?.call(() => stdoutTextWidget += stdout));
      await process.stderr.transform(utf8.decoder).forEach((stderr) =>
          setStateFromContent?.call(() => stdoutTextWidget += stderr));
    }
  }
}
