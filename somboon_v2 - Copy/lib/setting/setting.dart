import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:somboon_v2/provider/provider.dart';
import '../print/testprint.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();

  static void sample(BuildContext context, Map<String, dynamic> qrData) {}
}

class _SettingScreenState extends State<SettingScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  TestPrint testPrint = TestPrint();

  bool isChecked = false;
  late DataProvider _dataProvider;

  // @override
  // void initState() {
  //   super.initState();
  //   initPlatformState();
  //   initPlatformState1();
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataProvider = Provider.of<DataProvider>(context);
    initPlatformState();
    initPlatformState1();
  }

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {}

    // Load previously connected device address from Hive
    var PrinterBox = await Hive.openBox('PrinterDevice');
    String? savedAddress = PrinterBox.get('PrinterDevice');
    // await PrinterBox.close();

    if (savedAddress != null) {
      BluetoothDevice? savedDevice = devices.firstWhere(
        (device) => device.address == savedAddress,
      );

      if (savedDevice != null) {
        if (mounted) {
          setState(() {
            _connected = true;
            _device = savedDevice;
          });
        }

        // Attempt to connect to the saved device
        bluetooth.connect(savedDevice).then((_) {
          if (mounted) {
            setState(() {
              _connected = true;
            });
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _connected = false;
            });
          }
        });
      }
    }

    bluetooth.onStateChanged().listen((state) {
      if (mounted) {
        switch (state) {
          case BlueThermalPrinter.CONNECTED:
            setState(() {
              _connected = true;
              print("bluetooth device state: connected");
            });
            break;
          case BlueThermalPrinter.DISCONNECTED:
            setState(() {
              _connected = false;
              print("bluetooth device state: disconnected");
            });
            break;
          // Handle other states
          default:
            print(state);
            break;
        }
      }
    });

    if (mounted) {
      setState(() {
        _devices = devices;
      });
    }

    if (isConnected == true) {
      if (mounted) {
        setState(() {
          _connected = true;
        });
      }
    }
  }

  Future<void> addToHive(String GiveName) async {
    Provider.of<DataProvider>(context, listen: false)
        .setGiveNameValue(GiveName);
    setState(() {});
  }

  Future<void> initPlatformState1() async {
    final hiveData = Provider.of<DataProvider>(context);
    String? storedValue = hiveData.givenameValue ?? "Loading...";
    if (storedValue == 'Checked') {
      setState(() {
        isChecked = true;
      });
    }
  }

  void _onCheckboxChanged(bool? value) {
    setState(() {
      isChecked = value ?? false;
      addToHive(isChecked ? 'Checked' : 'Unchecked');
    });
  }

  @override
  void dispose() {
    super.dispose();
    bluetooth.disconnect(); // Ensure disconnection on dispose
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
      appBar: AppBar(
        title: const Text(
          'เลือกเครื่องพิมพ์',
          style: TextStyle(
            fontSize: 25.0,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(width: 10),
                const Text(
                  'Device:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: DropdownButton(
                    items: _getDeviceItems(),
                    onChanged: (BluetoothDevice? value) =>
                        setState(() => _device = value),
                    value: _device,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                  onPressed: () {
                    initPlatformState();
                  },
                  child: const Text(
                    'Refresh',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _connected ? Colors.red : Colors.green),
                  onPressed: _connected ? _disconnect : _connect,
                  child: Text(
                    _connected ? 'Connected' : 'Connect',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: 1.5,
                  child: Checkbox(
                    value: isChecked,
                    onChanged: _onCheckboxChanged,
                  ),
                ),
                const SizedBox(width: 20),
                const Text(
                    'ทำการ เพิ่มชื่อ และ เบอร์โทรศัพท์ของลูกค้าได้\nGive Name & Phone In Numpad',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                onPressed: () {
                  testPrint.sample();
                },
                child: const Text('PRINT TEST',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name ?? ""),
          value: device,
        ));
      });
    }
    return items;
  }

  void _connect() async {
    if (_device != null) {
      bool? isConnected = await bluetooth.isConnected;
      if (!isConnected!) {
        bluetooth.connect(_device!).then((_) async {
          var PrinterBox = await Hive.openBox('PrinterDevice');
          await PrinterBox.put('PrinterDevice', _device!.address);
          await PrinterBox.close();
          if (mounted) {
            setState(() => _connected = true);
          }
        }).catchError((error) {
          if (mounted) {
            setState(() => _connected = false);
          }
        });
      }
    } else {
      show('No device selected.');
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    if (mounted) {
      setState(() => _connected = false);
    }
  }

  Future show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          duration: duration,
        ),
      );
    }
  }
}
