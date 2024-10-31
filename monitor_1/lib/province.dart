import 'package:flutter/material.dart';

class WifiIPProvider with ChangeNotifier {
  String? _wifiIP;

  String? get wifiIP => _wifiIP;

  void setWifiIP(String? wifiIP) {
    _wifiIP = wifiIP;
    notifyListeners();
  }
}
