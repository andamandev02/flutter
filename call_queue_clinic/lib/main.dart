import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('numbers'); // เปิด Hive box สำหรับ numbers
  await Hive.openBox<String>('rooms'); // เปิด Hive box สำหรับ rooms
  await Hive.openBox('ModeSounds'); // เปิด Hive box สำหรับ ModeSounds
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FocusNode focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final int maxItems = 2;

  bool _isPlaying = false;

  int _firstIndex = 0;

  bool _isBlinking = false;
  Timer? _blinkTimer;

  Box? modeBox; // เพิ่มตัวแปรสำหรับเก็บ box

  void _startBlinking() {
    setState(() {
      _isBlinking = true;
    });

    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _isBlinking = !_isBlinking;
      });
    });
  }

  void _stopBlinking() {
    _blinkTimer?.cancel();
    setState(() {
      _isBlinking = false;
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  void _handleSubmitted(String value) async {
    final numbersBox = Hive.box<String>('numbers');
    final roomsBox = Hive.box<String>('rooms');

    if (!value.contains('+') &&
        !value.contains('.') &&
        !value.contains('*') &&
        !value.contains('/') &&
        !value.contains('-')) {
      _controller.clear();
      FocusScope.of(context).requestFocus(focusNode);
      return;
    }

    final parts = value.split('+');

    if (value.startsWith('***')) {
      _handleModeChange(value);
    } else if (parts.length == 2) {
      String num1 = parts[0].trim();
      String num2 = parts[1].trim();

      if (num1.length > 3) num1 = num1.substring(0, 3);
      if (num2.length > 1) num2 = num2.substring(0, 1);

      if (num1.isEmpty) {
        final rooms = roomsBox.values.toList();
        final index = rooms.indexOf(num2);
        if (index != -1 && index < numbersBox.length) {
          String numOLD = numbersBox.getAt(index) ?? '';
          int numOLDInt = int.parse(numOLD);
          int numNew = numOLDInt + 1;

          if (numbersBox.length == maxItems) await numbersBox.deleteAt(0);
          if (roomsBox.length == maxItems) await roomsBox.deleteAt(0);

          await numbersBox.add(numNew.toString());
          await roomsBox.add(num2);
          PlaySound(numNew.toString(), num2);
        }
      } else if (num1.isNotEmpty && num2.isNotEmpty) {
        if (numbersBox.length == maxItems) await numbersBox.deleteAt(0);
        if (roomsBox.length == maxItems) await roomsBox.deleteAt(0);

        await numbersBox.add(num1);
        await roomsBox.add(num2);
        PlaySound(num1, num2);
      }
      _startBlinking();
      _controller.clear();
      FocusScope.of(context).requestFocus(focusNode);
    } else if (value.startsWith('.')) {
      if (value.length > 1) {
        setState(() {
          _isPlaying = false;
          focusNode.requestFocus();
          _controller.clear();
        });
      } else {
        if (numbersBox.isNotEmpty && roomsBox.isNotEmpty) {
          String latestNum1 = numbersBox.getAt(numbersBox.length - 1) ?? '';
          String latestNum2 = roomsBox.getAt(roomsBox.length - 1) ?? '';
          PlaySound(latestNum1, latestNum2);
          _startBlinking();
          _controller.clear();
          FocusScope.of(context).requestFocus(focusNode);
        }
      }
    } else if (value.startsWith('-')) {
      setState(() {
        _isPlaying = false;
        focusNode.requestFocus();
        _controller.clear();
      });
    } else {
      await clearHiveBox();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });

    _initializeHiveBox(); // เรียกใช้ฟังก์ชันเพื่อเปิด box
  }

  Future<void> _initializeHiveBox() async {
    var box = await Hive.openBox('ModeSounds');

    if (box.get('mode') == null) {
      box.put('mode', '2'); // กำหนดค่าเป็น '2'
    }

    setState(() {
      modeBox = box;
    });
  }

  void clearAllHiveBoxes() {
    final numbersBox = Hive.box<String>('numbers');
    final roomsBox = Hive.box<String>('rooms');

    numbersBox.clear();
    roomsBox.clear();
    _controller.clear();
    FocusScope.of(context).requestFocus(focusNode);
  }

  void _handleModeChange(String value) async {
    String numberPart = value.substring(3);
    if (numberPart.isNotEmpty && int.tryParse(numberPart) != null) {
      await clearHiveBox();
      await _addToHive(numberPart);
      var box = await Hive.openBox('ModeSounds');
      var modes = box.values.toList();
      for (var mode in modes) {
        _showModeChangeDialog(mode);
      }
    } else {
      focusNode.requestFocus();
      _controller.clear();
    }
  }

  Future<void> clearHiveBox() async {
    var box = await Hive.openBox('ModeSounds');
    await box.clear();
    await box.deleteFromDisk();
  }

  void _showModeChangeDialog(String mode) {
    String title, content;
    switch (mode) {
      case '1':
        title = 'MODE 1 : ที่ห้องตรวจ';
        content = '';
        break;
      case '2':
        title = 'MODE 2 : Counter';
        content = '';
        break;
      case '3':
        title = 'MODE 3 : ช่องบริการ';
        content = '';
        break;
      default:
        title = 'MODE 1 : ที่ห้องตรวจ';
        content = '';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        const duration = Duration(seconds: 2);
        Timer(duration, () {
          Navigator.of(context).pop();
        });
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 35),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
    focusNode.requestFocus();
    _controller.clear();
  }

  Future<void> _addToHive(String mode) async {
    var box = await Hive.openBox('ModeSounds');
    await box.put('mode', mode);
    setState(() {});
  }

  void PlaySound(String num1, String num2) async {
    try {
      final _player = AudioPlayer();

      setState(() {
        _isPlaying = true;
      });

      if (num1.length > 3) {
        num1 = num1.substring(0, 3);
      }

      // ตัดตัวท้ายออกหาก num2 มีเกิน 2 หลัก
      if (num2.length > 2) {
        num2 = num2.substring(0, 2);
      }

      var box = await Hive.openBox('ModeSounds');
      var mode = box.getAt(0);

      Future<void> playNumberSound(String number) async {
        for (int i = 0; i < number.length; i++) {
          await _player.play(AssetSource('soundtrack/${number[i]}.mp3'));

          await _player.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
            orElse: () => PlayerState.completed,
          );

          if (i + 1 < number.length && number[i] != number[i + 1]) {
            await Future.delayed(const Duration(milliseconds: 50));
          }
        }
      }

      Future<void> playSoundtrack(String path, int delay) async {
        await _player.play(AssetSource(path));
        await Future.delayed(Duration(milliseconds: delay));
      }

      if (mode == '1') {
        await playSoundtrack('soundtrack/เชิญหมายเลข.mp3', 1200);
        await playNumberSound(num1);
        await playSoundtrack('soundtrack/ที่ห้องตรวจหมายเลข.mp3', 1200);
        await playNumberSound(num2);
      } else if (mode == '2') {
        await playSoundtrack('soundtrack/เชิญหมายเลข.mp3', 1200);
        await playNumberSound(num1);
        await playSoundtrack('soundtrack/ที่เค้าเตอร์หมายเลข.mp3', 1200);
        await playNumberSound(num2);
      } else if (mode == '3') {
        await playSoundtrack('soundtrack/เชิญหมายเลข.mp3', 1200);
        await playNumberSound(num1);
        await playSoundtrack('soundtrack/ที่ช่องบริการ.mp3', 1200);
        await playNumberSound(num2);
      }

      _stopBlinking();

      setState(() {
        _isPlaying = false;
        focusNode.requestFocus();
        _controller.clear();
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          const duration = Duration(seconds: 2);
          Timer(duration, () {
            Navigator.of(context).pop();
          });
          return AlertDialog(
            title: Text(
              '${e}',
              style: const TextStyle(fontSize: 35),
              textAlign: TextAlign.center,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = screenHeight * 0.25;
    final headerHeightH = screenHeight * 0.5;

    final double itemHeight = (screenHeight - headerHeight) / maxItems;
    final double itemHeightHeader = (screenHeight - headerHeightH) / maxItems;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(focusNode);
      },
      child: Scaffold(
        body: ValueListenableBuilder(
          valueListenable: Hive.box<String>('numbers').listenable(),
          builder: (context, Box<String> numbersBox, _) {
            final numbers = numbersBox.values.toList().reversed.toList();
            final rooms =
                Hive.box<String>('rooms').values.toList().reversed.toList();

            // Ensure we have at least 4 items to display
            final maxItems = 2;
            final itemCount = maxItems;

            return Column(
              children: [
                Stack(
                  children: [
                    AbsorbPointer(
                      absorbing: _isPlaying,
                      child: Opacity(
                        opacity: _isPlaying ? 0 : 0,
                        child: TextField(
                          focusNode: focusNode,
                          controller: _controller,
                          onChanged: (value) {
                            if (value == '/') {
                              clearAllHiveBoxes();
                            }
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(_isPlaying
                                ? RegExp(r'')
                                : RegExp(r'[\d+-.*/]')),
                          ],
                          onSubmitted: (value) {
                            if (!_isPlaying) {
                              _handleSubmitted(value);
                            }
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: itemHeightHeader,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Center(
                              child: Text(
                                'หมายเลข',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 208, 255, 0),
                                  fontSize: 100,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            color: Colors.white,
                          ),
                          Expanded(
                            child: FutureBuilder<String>(
                              future:
                                  _getModeDisplayText(), // เรียกใช้งานฟังก์ชันที่คืนค่า Future
                              builder: (context, snapshot) {
                                return Center(
                                  child: Text(
                                    snapshot.data ?? 'ห้องตรวจ',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 208, 255, 0),
                                      fontSize: 100,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      final num1 =
                          index < numbers.length ? numbers[index] : '-';
                      final num2 = index < rooms.length ? rooms[index] : '-';

                      bool shouldBlink = _isBlinking && index == _firstIndex;

                      return GestureDetector(
                        child: Container(
                          height: itemHeight,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    child: Text(
                                      '$num1',
                                      key: ValueKey<bool>(shouldBlink),
                                      style: TextStyle(
                                        color: shouldBlink
                                            ? Colors.red
                                            : Colors.white,
                                        fontSize: 200, // ลดขนาดฟอนต์
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                color: Colors.white,
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment
                                      .topCenter, // จัดตำแหน่งข้อความให้ชิดด้านบน
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    child: Text(
                                      '$num2',
                                      key: ValueKey<bool>(shouldBlink),
                                      style: TextStyle(
                                        color: shouldBlink
                                            ? Colors.red
                                            : Colors.white,
                                        fontSize: 200, // ลดขนาดฟอนต์
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<String> _getModeDisplayText() async {
    var box = await Hive.openBox('ModeSounds');
    // if (box.get('mode') == null) {
    //   box.put('mode', '2');
    // }

    String mode = box.get('mode');

    switch (mode) {
      case '1':
        return 'ห้องตรวจ';
      case '2':
        return 'Counter';
      case '3':
        return 'ช่องบริการ';
      default:
        return 'ห้องตรวจ';
    }
  }
}
