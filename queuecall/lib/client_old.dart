// @dart = 2.12
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

typedef Unit8ListCallback = Function(Uint8List data);
typedef DynamicCallback = Function(dynamic data);

final deviceInfo = DeviceInfoPlugin();
final deviceInfo1 = DeviceInfoPlugin();
final deviceInfo2 = DeviceInfoPlugin();

class ClientModel {
  String hostname;
  int port;
  Unit8ListCallback onData;
  DynamicCallback onError;

  ClientModel(
      {required this.hostname,
      required this.port,
      required this.onData,
      required this.onError});

  bool isConnected = false;
  Socket? socket;

  Future<void> connect() async {
    try {
      socket = await Socket.connect(hostname, port);
      socket!.listen(onData, onError: onError, onDone: () async {
        final info = await deviceInfo.androidInfo;
        final info1 = await deviceInfo1.androidInfo;
        final info2 = await deviceInfo2.androidInfo;
        disconnect(info);
        disconnect(info1);
        disconnect(info2);
        isConnected = false;
      });
      isConnected = true;
      print(socket!.address);
    } catch (e) {
      debugPrint("error in connnect : $e");
    }
  }

  void write(String message) {
    print(message);
    socket?.write(message);
  }

  void disconnect(AndroidDeviceInfo androidDeviceInfo) {
    final message =
        "${androidDeviceInfo.brand} ${androidDeviceInfo.device} got disconnect";
    write(message);
    if (socket != null) {
      socket!.destroy();
    }
    isConnected = false;
  }
}
