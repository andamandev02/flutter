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
  final int maxItems = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void clearAllHiveBoxes() {
    final numbersBox = Hive.box<String>('numbers');
    final roomsBox = Hive.box<String>('rooms');

    numbersBox.clear();
    roomsBox.clear();
    _controller.clear();
    FocusScope.of(context).requestFocus(focusNode);
  }

  void _handleSubmitted(String value) async {
    final numbersBox = Hive.box<String>('numbers');
    final roomsBox = Hive.box<String>('rooms');

    final parts = value.split('+');

    if (value.startsWith('***')) {
      _handleModeChange(value);
    } else if (parts.length == 2) {
      String num1 = parts[0].trim();
      String num2 = parts[1].trim();

      // ตัดตัวท้ายหาก num1 มีเกิน 3 หลัก
      if (num1.length > 3) {
        num1 = num1.substring(0, 3);
      }

      // ตัดตัวท้ายหาก num2 มีเกิน 2 หลัก
      if (num2.length > 2) {
        num2 = num2.substring(0, 2);
      }

      if (num1 == '') {
        final num1 = parts[0].trim();
        final num2 = parts[1].trim();

        if (num1.isEmpty) {
          final rooms = roomsBox.values.toList();
          final index = rooms.indexOf(num2);

          if (index != -1) {
            if (index < numbersBox.length) {
              String numOLD = numbersBox.getAt(index) ?? '';
              int numOLDInt = int.parse(numOLD);
              int numNew = numOLDInt + 1;

              if (numbersBox.length == maxItems) {
                await numbersBox.deleteAt(0);
              }
              if (roomsBox.length == maxItems) {
                await roomsBox.deleteAt(0);
              }

              await numbersBox.add(numNew.toString());
              await roomsBox.add(num2);
              PlaySound(numNew.toString(), num2);
              setState(() {});
            }
          }
          if (num1.isEmpty) {
            print("Could not find num1 for num2: $num2");
          }
        }
      } else {
        if (num1.isNotEmpty && num2.isNotEmpty) {
          if (numbersBox.length == maxItems) {
            await numbersBox.deleteAt(0);
          }
          if (roomsBox.length == maxItems) {
            await roomsBox.deleteAt(0);
          }
          await numbersBox.add(num1);
          await roomsBox.add(num2);
          PlaySound(num1, num2);
          setState(() {});
        }
      }
      _controller.clear();
      FocusScope.of(context).requestFocus(focusNode);
    } else if (value.startsWith('.')) {
      if (numbersBox.isNotEmpty && roomsBox.isNotEmpty) {
        String latestNum1 = numbersBox.getAt(numbersBox.length - 1) ?? '';
        String latestNum2 = roomsBox.getAt(roomsBox.length - 1) ?? '';
        PlaySound(latestNum1, latestNum2);
        _controller.clear();
        FocusScope.of(context).requestFocus(focusNode);
      }
    }
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
    await box.close();
    setState(() {});
  }

  void PlaySound(String num1, String num2) async {
    try {
      final _player = AudioPlayer();
      // ตัดตัวท้ายออกหาก num1 มีเกิน 3 หลัก
      if (num1.length > 3) {
        num1 = num1.substring(0, 3);
      }

      // ตัดตัวท้ายออกหาก num2 มีเกิน 2 หลัก
      if (num2.length > 2) {
        num2 = num2.substring(0, 2);
      }

      // num1 = num1.padLeft(2, '0');
      // num2 = num2.padLeft(2, '0');

      var box = await Hive.openBox('ModeSounds');
      var mode = box.getAt(0);

      Future<void> playNumberSound(String number) async {
        for (int i = 0; i < number.length; i++) {
          await _player.play(AssetSource('sounds/${number[i]}.mp3'));

          // รอจนกว่าการเล่นไฟล์เสียงจะจบ
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
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = screenHeight * 0.2;

    final double itemHeight = (screenHeight - headerHeight) / maxItems;

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
            final maxItems = 4;
            final itemCount = maxItems;

            return Column(
              children: [
                Container(
                  height: itemHeight,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            children: [
                              Expanded(
                                child: Opacity(
                                  opacity: 0,
                                  child: TextField(
                                    focusNode: focusNode,
                                    controller: _controller,
                                    onChanged: (value) {
                                      if (value == '/') {
                                        clearAllHiveBoxes();
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'กรอกหมายเลข',
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[\d+-.*/]')),
                                    ],
                                    style: const TextStyle(fontSize: 16),
                                    onSubmitted: _handleSubmitted,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  width:
                                      10), // Add some spacing between the TextField and the label
                              const Text(
                                'หมายเลข',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 208, 255, 0),
                                  fontSize: 100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 2,
                        color: Colors.white,
                      ),
                      Expanded(
                        child: FutureBuilder(
                          future: Hive.openBox('ModeSounds'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              var box = Hive.box('ModeSounds');
                              var mode = box.get('mode', defaultValue: '1');
                              String displayText;
                              switch (mode) {
                                case '1':
                                  displayText = 'ห้องตรวจ';
                                  break;
                                case '2':
                                  displayText = 'Counter';
                                  break;
                                case '3':
                                  displayText = 'ช่องบริการ';
                                  break;
                                default:
                                  displayText = 'ห้องตรวจ';
                              }

                              return Center(
                                child: Text(
                                  displayText,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 208, 255, 0),
                                    fontSize: 100,
                                  ),
                                ),
                              );
                            } else {
                              // While the Hive box is being opened, display a loading indicator
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      // Determine the value for num1 and num2 at this index
                      final num1 =
                          index < numbers.length ? numbers[index] : '-';
                      final num2 = index < rooms.length ? rooms[index] : '-';

                      Color backgroundColor =
                          const Color.fromARGB(255, 0, 0, 0);

                      return GestureDetector(
                        child: Container(
                          height: itemHeight,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '$num1',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 120,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 2,
                                color: Colors.white,
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '$num2',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 120,
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
}
