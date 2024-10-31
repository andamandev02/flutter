import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

import 'client.dart';

class ClientController extends GetxController {
  ClientModel? clientModel;
  List<String> logs = [];
  int port = 9001;
  Stream<NetworkAddress>? stream;
  NetworkAddress? address;
  final NetworkInfo _networkInfo = NetworkInfo();

  @override
  void onInit() {
    getIpAddress();
    super.onInit();
  }

  getIpAddress() async {
    stream = NetworkAnalyzer.discover2("192.168.0", port);
    stream!.listen((NetworkAddress networkAddress) {
      if (networkAddress.exists) {
        address = networkAddress;
        clientModel = ClientModel(
            hostname: networkAddress.ip,
            onData: OnData,
            onError: onError,
            port: port);
      }
    });
    update();
  }

  void sendMessage(String message) {
    String formattedDateTime =
        DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
    logs.add("Call Pad : $message ($formattedDateTime)");
    clientModel?.write(message);
    update();
  }

  OnData(Uint8List data) {
    final message = String.fromCharCodes(data);
    logs.add(message);
    update();
  }

  onError(dynamic error) {
    debugPrint("Error : $error");
  }
}
