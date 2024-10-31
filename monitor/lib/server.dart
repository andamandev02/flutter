import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';

typedef Unit8ListCallback = Function(Uint8List data);
typedef DynamicCallback = Function(dynamic data);
final NetworkInfo _networkInfo = NetworkInfo();

class Server {
  Unit8ListCallback? onData;
  DynamicCallback? onError;

  Server(this.onData, this.onError);

  ServerSocket? server;
  bool running = false;
  List<Socket> sockets = [];
  String? wifiIPv4S;
  // String? wifiIPv4S = '192.168.0.117';

  Future<String?> start() async {
    final networkInfo = NetworkInfo();
    wifiIPv4S = await networkInfo.getWifiIP();
    try {
      runZoned(() async {
        server = await ServerSocket.bind(wifiIPv4S, 9000);
        running = true;
        server!.listen(onRequest);
      }, onError: onError);
    } catch (e) {
      return null;
    }
  }

  void onRequest(Socket socket) {
    if (!sockets.contains(socket)) {
      sockets.add(socket);
    }
    socket.listen((event) {
      onData!(event);
    });
  }

  Future<void> close() async {
    await server!.close();
    server = null;
    running = false;
  }

  void broadcast(String data) {
    // onData!(Uint8List.fromList("Client : $data".codeUnits));
    for (final socket in sockets) {
      socket.write(data);
    }
  }
}
