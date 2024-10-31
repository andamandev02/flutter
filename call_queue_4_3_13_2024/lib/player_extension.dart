import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';

extension PlayerExtension on AudioPlayer {
  Future<void> addAssets({required String asset}) async {
    final complete = Completer<void>();
    await setAsset('assets/$asset');

    Platform.isWindows
        ? await Future.delayed(const Duration(seconds: 1), complete.complete)
        : complete.complete();
    return await complete.future;
  }
}
