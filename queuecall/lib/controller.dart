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
  List<ClientModel> clientModels = [];
  List<String> logs = [];
  // int port = 9000;
  Stream<NetworkAddress>? stream;
  List<NetworkAddress> addresses = [];
  final NetworkInfo _networkInfo = NetworkInfo();

  @override
  void onInit() {
    getIpAddresses();
    super.onInit();
  }

  // getIpAddresses() async {
  //   // สร้าง Stream สำหรับสแกน IP Address ในพอร์ต 9000
  //   stream = NetworkAnalyzer.discover2("192.168.0", port);
  //   stream!.listen((NetworkAddress networkAddress) async {
  //     if (networkAddress.exists) {
  //       // Check if the IP address already exists in the list
  //       bool isExisting =
  //           addresses.any((address) => address.ip == networkAddress.ip);
  //       if (!isExisting) {
  //         final socket = await Socket.connect(networkAddress.ip, port,
  //             timeout: const Duration(milliseconds: 100));
  //         socket.destroy(); // Close the connection
  //         addresses.add(networkAddress);
  //         final clientModel = ClientModel(
  //             hostname: networkAddress.ip,
  //             onData: OnData,
  //             onError: onError,
  //             port: port);
  //         clientModels.add(clientModel);
  //         update();
  //       }
  //     }
  //   });
  // }

  getIpAddresses() async {
    final List<int> portsToScan = [9000, 9001, 9002]; // ระบุพอร์ตที่ต้องการสแกน
    final List<String> subnetsToScan = [
      "192.168.0",
      "192.168.1",
      "192.168.60"
    ]; // ระบุเน็ตเวิร์กของพอร์ตที่ต้องการสแกน

    for (final subnet in subnetsToScan) {
      for (final port in portsToScan) {
        // สร้าง Stream สำหรับสแกน IP Address ในพอร์ตที่กำหนด
        stream = NetworkAnalyzer.discover2(subnet, port);
        await for (NetworkAddress networkAddress in stream!) {
          if (networkAddress.exists) {
            // Check if the IP address already exists in the list
            bool isExisting =
                addresses.any((address) => address.ip == networkAddress.ip);
            if (!isExisting) {
              final socket = await Socket.connect(networkAddress.ip, port,
                  timeout: const Duration(milliseconds: 100));
              socket.destroy(); // Close the connection
              addresses.add(networkAddress);
              final clientModel = ClientModel(
                hostname: networkAddress.ip,
                onData: OnData,
                onError: onError,
                port: port,
              );
              clientModels.add(clientModel);
              update();
            }
          }
        }
      }
    }
  }

  void sendMessage(String message) {
    String formattedDateTime =
        DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
    logs.add("Call Pad : $message ($formattedDateTime)");
    for (final clientModel in clientModels) {
      clientModel.write(message);
    }
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
