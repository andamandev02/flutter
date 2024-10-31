import 'package:monitor/server.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ServerController extends GetxController {
  Server? server;
  List<String> serverLogs = [];
  TextEditingController messageController = TextEditingController();

  Future startOrStopServer() async {
    if (server!.running) {
      await server!.close();
      serverLogs.clear();
    } else {
      await server!.start();
    }
    update();
  }

  @override
  void onInit() {
    server = Server(onData, onError);
    super.onInit();
  }

  void onData(Uint8List data) {
    final receviedData = String.fromCharCodes(data);
    // debugPrint(receviedData);
    serverLogs.add(receviedData);
    update();
  }

  void onError(dynamic error) {
    // debugPrint("ERROR: + $error");
  }

  void handelMessage() {
    server!.broadcast(messageController.text);
    // serverLogs.add(messageController.text);
    messageController.clear();
    update();
  }
}
