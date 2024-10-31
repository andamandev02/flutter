import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveConnectedDevice(String ip, int port) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String key = 'connected_device_$ip';
  prefs.setInt('$key-port', port);
}

Future<List<Map<String, dynamic>>> getConnectedDevices() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Set<String> keys = prefs.getKeys();
  List<Map<String, dynamic>> devices = [];
  for (String key in keys) {
    if (key.startsWith('connected_device_')) {
      String ip = key.split('_').last;
      int? port = prefs.getInt('$key-port');
      devices.add({'ip': ip, 'port': port});
    }
  }
  return devices;
}
