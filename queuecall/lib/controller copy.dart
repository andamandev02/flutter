import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
import 'dart:developer' as developer;

import 'client.dart';

class ClientController extends GetxController {
  ClientModel? clientModel;
  ClientModel? clientModel1;
  ClientModel? clientModel2;
  List<String> logs = [];
  int port = 9000;
  int port1 = 9001;
  int port2 = 9002;
  Stream<NetworkAddress>? stream;
  Stream<NetworkAddress>? stream1;
  Stream<NetworkAddress>? stream2;
  NetworkAddress? address;
  NetworkAddress? address1;
  NetworkAddress? address2;
  final NetworkInfo _networkInfo = NetworkInfo();
  String? wifiIPv4S;
  String? truncatedIpAddress;

  @override
  void onInit() {
    getIpAddress();
    super.onInit();
  }

  Future<void> _initNetworkInfo() async {
    String? wifiIPv4;
    try {
      wifiIPv4 = await _networkInfo.getWifiIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv4', error: e);
      wifiIPv4 = 'Failed to get Wifi IPv4';
    }

    wifiIPv4S = '$wifiIPv4';
  }

  getIpAddress() async {
    stream = NetworkAnalyzer.discover("192.168.0", port);
    // stream1 = NetworkAnalyzer.discover("192.168.0", port1);
    // stream2 = NetworkAnalyzer.discover("192.168.0", port2);

    // Variables to keep track of discovered IP and port combinations
    Set<String> discoveredCombinations = Set<String>();

    stream!.listen((NetworkAddress networkAddress) {
      String combination = "${networkAddress.ip}:$port";
      if (networkAddress.exists &&
          !discoveredCombinations.contains(combination)) {
        address = networkAddress;
        clientModel = ClientModel(
          hostname: networkAddress.ip,
          onData: OnData,
          onError: onError,
          port: port,
        );
        discoveredCombinations.add(combination);
      }
    });

    // stream1!.listen((NetworkAddress networkAddress) {
    //   String combination1 = "${networkAddress.ip}:$port1";
    //   if (networkAddress.exists &&
    //       !discoveredCombinations.contains(combination1)) {
    //     address1 = networkAddress;
    //     clientModel1 = ClientModel(
    //       hostname: networkAddress.ip,
    //       onData: OnData,
    //       onError: onError,
    //       port: port1,
    //     );
    //     discoveredCombinations.add(combination1);
    //   }
    // });

    // stream2!.listen((NetworkAddress networkAddress) {
    //   String combination2 = "${networkAddress.ip}:$port2";
    //   if (networkAddress.exists &&
    //       !discoveredCombinations.contains(combination2)) {
    //     address2 = networkAddress;
    //     clientModel2 = ClientModel(
    //       hostname: networkAddress.ip,
    //       onData: OnData,
    //       onError: onError,
    //       port: port2,
    //     );
    //     discoveredCombinations.add(combination2);
    //   }
    // });
    update();
  }

  void sendMessage(String message) {
    String formattedDateTime =
        DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
    logs.add("Call Pad : $message ($formattedDateTime)");
    clientModel?.write(message);
    // clientModel1?.write(message);
    // clientModel2?.write(message);
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
