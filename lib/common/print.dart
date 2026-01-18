import 'dart:io';

import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CommonPrint {
  static CommonPrint? _instance;
  static Future<String>? _logFilePathFuture;

  CommonPrint._internal();

  factory CommonPrint() {
    _instance ??= CommonPrint._internal();
    return _instance!;
  }

  log(String? text) {
    final payload = "[FlClash] $text";
    debugPrint(payload);
    _writeToFile(payload);
    if (!globalState.isInit) {
      return;
    }
    globalState.appController.addLog(
      Log.app(payload),
    );
  }

  Future<void> _writeToFile(String payload) async {
    try {
      _logFilePathFuture ??= _resolveLogFilePath();
      final logFilePath = await _logFilePathFuture!;
      final timestamp = DateTime.now().toIso8601String();
      final line = "[$timestamp] $payload\n";
      await File(logFilePath).writeAsString(
        line,
        mode: FileMode.append,
        flush: false,
      );
    } catch (_) {
      // Ignore file logging errors to avoid crashing startup.
    }
  }

  Future<String> _resolveLogFilePath() async {
    final baseDir = await getApplicationSupportDirectory();
    final logDir = Directory(join(baseDir.path, "logs"));
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    return join(logDir.path, "app_startup.log");
  }
}

final commonPrint = CommonPrint();
