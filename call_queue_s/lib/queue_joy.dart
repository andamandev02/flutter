// ignore_for_file: unrelated_type_equality_checks

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({Key? key}) : super(key: key);

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _value = '000';
  bool _isPlaying = false;
  final List<String> _valueList = [];
  int maxDigits = 3; // จำนวนตัวเลขสูงสุดที่อนุญาต
  // ignore: non_constant_identifier_names
  final List<String> _valueList_last = [];

  Future<void> _handleSubmit(String value) async {
    if (_isPlaying) {
      return;
    }
    if (value.startsWith('-') && int.tryParse(value.substring(1)) != null) {
      _handleMinus(value);
    } else if (value == '*') {
      _handleMultiply();
    } else if (int.tryParse(value) != null) {
      _handleNumericValue(value);
      // } else if (value == '.') {
      //   _handleDot();
    } else if (value == '---') {
      _handleReset();
    } else if (value.startsWith('***')) {
      _handleModeChange(value);
    } else if (RegExp(r'[^\d+-.*/]').hasMatch(value)) {
      _handleInvalidCharacter();
    } else if (value.startsWith('/')) {
      _handleSlash(value);
    } else {
      _handleOtherCases();
    }
  }

  void _handlePlus() async {
    print("+");
    int currentValue = int.parse(_value);
    _value = (currentValue + 1).toString().padLeft(0, '0');
    _startFlash();
    await _playSound(_value);
    _stopFlash();
    _focusNode.requestFocus();
    _textController.clear();
  }

  void _handleMinus(String value) {
    print("เอาออกจาก array");
    String numberPart = value.substring(1);
    if (numberPart.isNotEmpty && int.tryParse(numberPart) != null) {
      if (_valueList_last.contains(numberPart)) {
        setState(() {
          _valueList_last.remove(numberPart);
        });
        _focusNode.requestFocus();
        _textController.clear();
      } else {
        _focusNode.requestFocus();
        _textController.clear();
      }
    } else {
      _focusNode.requestFocus();
      _textController.clear();
    }
  }

  void _handleMultiply() {
    print("เคลียค่า");
    setState(() {
      _value = '000';
    });
    _focusNode.requestFocus();
    _textController.clear();
  }

  Future<void> _handleClearText() async {
    print("เคลียค่า Text");
    _focusNode.requestFocus();
    _textController.clear();
  }

  Future<void> _handleNumericValue(String value) async {
    print("รับค่าตัวเลขตรงๆ");
    _value = value.toString().padLeft(3, '0');
    _startFlash();
    await _playSound(_value);
    _stopFlash();
  }

  void _handleDot() async {
    int currentValue = int.parse(_value);
    _value = (currentValue).toString().padLeft(3, '0');
    _startFlash();
    await _playSound(_value);

    _focusNode.requestFocus();
    _textController.clear();
  }

  void _handleReset() {
    print("ลบออกหมดทุกอย่าง");
    setState(() {
      _valueList.clear();
      _valueList_last.clear();
      _value = '000';
    });
    _focusNode.requestFocus();
    _textController.clear();
  }

  void _handleModeChange(String value) async {
    print("เปลี่ยนโหมดเสียง");
    String numberPart = value.substring(3);
    if (numberPart.isNotEmpty && int.tryParse(numberPart) != null) {
      await _addToHive(numberPart);
      var box = await Hive.openBox('ModeSounds');
      var mode = box.values.first;
      _showModeChangeDialog(mode);
    } else {
      _focusNode.requestFocus();
      _textController.clear();
    }
  }

  void _showModeChangeDialog(String mode) {
    String title, content;
    switch (mode) {
      case '1':
        title = 'กำลังทำการเปลี่ยนโหมด เสียงกระดิ่ง';
        content = 'Changing mode, bell sound |  ປ່ຽນໂໝດ, ສຽງກະດິ່ງ';
        break;
      case '2':
        title = 'กำลังทำการเปลี่ยนโหมด เล่นเสียง LOAS';
        content = 'Changing mode, LOAS sound |  ປ່ຽນໂໝດ, ຫຼິ້ນສຽງ ປະເທດລາວ';
        break;
      case '3':
        title = 'กำลังทำการเปลี่ยนโหมด เล่นเสียง EN';
        content = 'Changing mode, EN sound |  ປ່ຽນໂໝດ, ຫຼິ້ນສຽງ ພາສາອັງກິດ';
        break;
      case '4':
        title = 'กำลังทำการเปลี่ยนโหมด เล่นเสียง LOAS + EN';
        content =
            'Changing mode, LOAS sound + EN sound | ປ່ຽນໂໝດ, ຫຼິ້ນສຽງ ປະເທດລາວ + ຫຼິ້ນສຽງ ພາສາອັງກິດ';
        break;
      default:
        title = 'Unknown Mode';
        content = 'Unknown mode change';
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
            style: TextStyle(fontSize: 35),
            textAlign: TextAlign.center,
          ),
          content: Text(
            content,
            style: TextStyle(fontSize: 35),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
    _focusNode.requestFocus();
    _textController.clear();
  }

  void _handleInvalidCharacter() {
    _focusNode.requestFocus();
    _textController.clear();
  }

  void _handleSlash(String value) {
    print("เรียกแล้วไม่มา");
    String numberPart = value.substring(1);
    if (numberPart.isNotEmpty && int.tryParse(numberPart) != null) {
      setState(() {
        _isPlaying = false;
        if (numberPart != '000' || numberPart != '00' || numberPart != '0') {
          _valueList.add(numberPart);
          if (_valueList.isNotEmpty) {
            if (!_valueList_last.contains(numberPart)) {
              _valueList_last.add(numberPart);
              if (_valueList_last.length > 6) {
                _valueList_last.removeAt(0);
              }
            }
          }
        }
      });
      _focusNode.requestFocus();
      _textController.clear();
    } else {
      _focusNode.requestFocus();
      _textController.clear();
    }
  }

  void _handleOtherCases() {
    _focusNode.requestFocus();
    _textController.clear();
  }

  Future<void> _addToHive(String mode) async {
    var box = await Hive.openBox('ModeSounds');
    await box.put('mode', mode);
    await box.close();
    setState(() {});
  }

  // เล่นเสียง
  // Future<void> _playSound(String value) async {
  //   var box = await Hive.openBox('ModeSounds');
  //   var values = box.values.toList();
  //   var mode = box.values.first;
  //   if (mode == '1') {
  //     final player = AudioPlayer();
  //     final numberString = value.toString();
  //     await player.play(AssetSource('sound/bell.mp3'));
  //     await Future.delayed(Duration(milliseconds: 800));
  //     await player.play(AssetSource('sound/EN/pleasenumber.MP3'));
  //     await Future.delayed(Duration(milliseconds: 1500));
  //     int consecutiveZeros = 0;
  //     for (int i = 0; i < numberString.length; i++) {
  //       String digit = numberString[i];
  //       await player.play(AssetSource('sound/EN/$digit.mp3'));

  //       await player.onPlayerStateChanged.firstWhere(
  //         (state) => state == PlayerState.completed,
  //       );

  //       if (digit == '0' &&
  //           i < numberString.length - 1 &&
  //           numberString[i + 1] == '0') {
  //         consecutiveZeros++;
  //         if (consecutiveZeros > 1) {
  //           await Future.delayed(Duration(milliseconds: 500));
  //         }
  //       } else {
  //         consecutiveZeros = 0;
  //       }
  //       if (i < numberString.length - 1 && digit == numberString[i + 1]) {
  //         await Future.delayed(Duration(milliseconds: 100));
  //       }
  //     }
  //     _focusNode.requestFocus();
  //     _textController.clear();
  //     await player.onPlayerStateChanged
  //         .firstWhere((state) => state == PlayerState.completed);
  //     _stopFlash();
  //     await player.dispose();
  //   } else if (mode == '2') {
  //     final player = AudioPlayer();
  //     final numberString = value.toString();
  //     await player.play(AssetSource('sound/LOAS/pleasenumber.MP3'));
  //     await Future.delayed(Duration(milliseconds: 1500));
  //     int consecutiveZeros = 0;
  //     for (int i = 0; i < numberString.length; i++) {
  //       String digit = numberString[i];
  //       await player.play(AssetSource('sound/LOAS/$digit.mp3'));

  //       await player.onPlayerStateChanged.firstWhere(
  //         (state) => state == PlayerState.completed,
  //       );

  //       if (digit == '0' &&
  //           i < numberString.length - 1 &&
  //           numberString[i + 1] == '0') {
  //         consecutiveZeros++;
  //         if (consecutiveZeros > 1) {
  //           await Future.delayed(Duration(milliseconds: 500));
  //         }
  //       } else {
  //         consecutiveZeros = 0; // รีเซ็ตตัวแปรเมื่อตัวเลขถัดไปไม่ใช่ศูนย์
  //       }
  //       if (i < numberString.length - 1 && digit == numberString[i + 1]) {
  //         await Future.delayed(Duration(milliseconds: 100));
  //       }
  //     }
  //     _focusNode.requestFocus();
  //     _textController.clear();
  //     await player.onPlayerStateChanged
  //         .firstWhere((state) => state == PlayerState.completed);
  //     _stopFlash();
  //     // ปิดเสียง
  //     await player.dispose();
  //   } else if (mode == '3') {
  //     final player = AudioPlayer();
  //     final numberString = value.toString();
  //     await player.play(AssetSource('sound/EN/pleasenumber.MP3'));
  //     await Future.delayed(Duration(milliseconds: 1500));
  //     int consecutiveZeros = 0;
  //     for (int i = 0; i < numberString.length; i++) {
  //       String digit = numberString[i];
  //       await player.play(AssetSource('sound/EN/$digit.mp3'));

  //       await player.onPlayerStateChanged.firstWhere(
  //         (state) => state == PlayerState.completed,
  //       );

  //       if (digit == '0' &&
  //           i < numberString.length - 1 &&
  //           numberString[i + 1] == '0') {
  //         consecutiveZeros++;
  //         if (consecutiveZeros > 1) {
  //           await Future.delayed(Duration(milliseconds: 500));
  //         }
  //       } else {
  //         consecutiveZeros = 0; // รีเซ็ตตัวแปรเมื่อตัวเลขถัดไปไม่ใช่ศูนย์
  //       }
  //       if (i < numberString.length - 1 && digit == numberString[i + 1]) {
  //         await Future.delayed(Duration(milliseconds: 100));
  //       }
  //     }
  //     _focusNode.requestFocus();
  //     _textController.clear();
  //     await player.onPlayerStateChanged
  //         .firstWhere((state) => state == PlayerState.completed);
  //     _stopFlash();
  //     // ปิดเสียง
  //   } else if (mode == '4') {
  //     final player = AudioPlayer();
  //     final numberString = value.toString();
  //     await player.play(AssetSource('sound/LOAS/pleasenumber.MP3'));
  //     await Future.delayed(Duration(milliseconds: 1500));
  //     int consecutiveZeros = 0;
  //     for (int i = 0; i < numberString.length; i++) {
  //       String digit = numberString[i];
  //       await player.play(AssetSource('sound/LOAS/$digit.mp3'));

  //       await player.onPlayerStateChanged.firstWhere(
  //         (state) => state == PlayerState.completed,
  //       );

  //       if (digit == '0' &&
  //           i < numberString.length - 1 &&
  //           numberString[i + 1] == '0') {
  //         consecutiveZeros++;
  //         if (consecutiveZeros > 1) {
  //           await Future.delayed(Duration(milliseconds: 500));
  //         }
  //       } else {
  //         consecutiveZeros = 0; // รีเซ็ตตัวแปรเมื่อตัวเลขถัดไปไม่ใช่ศูนย์
  //       }
  //       if (i < numberString.length - 1 && digit == numberString[i + 1]) {
  //         await Future.delayed(Duration(milliseconds: 100));
  //       }
  //     }

  //     await Future.delayed(Duration(milliseconds: 500));
  //     await player.play(AssetSource('sound/EN/pleasenumber.MP3'));
  //     await Future.delayed(Duration(milliseconds: 1500));
  //     int consecutiveZeros2 = 0;
  //     for (int i = 0; i < numberString.length; i++) {
  //       String digit = numberString[i];
  //       await player.play(AssetSource('sound/EN/$digit.mp3'));

  //       await player.onPlayerStateChanged.firstWhere(
  //         (state) => state == PlayerState.completed,
  //       );

  //       if (digit == '0' &&
  //           i < numberString.length - 1 &&
  //           numberString[i + 1] == '0') {
  //         consecutiveZeros2++;
  //         if (consecutiveZeros2 > 1) {
  //           await Future.delayed(Duration(milliseconds: 500));
  //         }
  //       } else {
  //         consecutiveZeros2 = 0; // รีเซ็ตตัวแปรเมื่อตัวเลขถัดไปไม่ใช่ศูนย์
  //       }
  //       if (i < numberString.length - 1 && digit == numberString[i + 1]) {
  //         await Future.delayed(Duration(milliseconds: 100));
  //       }
  //     }
  //     _focusNode.requestFocus();
  //     _textController.clear();
  //     await player.onPlayerStateChanged
  //         .firstWhere((state) => state == PlayerState.completed);
  //     _stopFlash();
  //     // ปิดเสียง
  //   }
  // }

  Future<void> _playSound(String value) async {
    var box = await Hive.openBox('ModeSounds');
    var mode = box.values.first;
    final player = AudioPlayer();
    final numberString = value.toString();

    String language = mode == '1' || mode == '3' ? 'EN' : 'LOAS';
    String pleaseNumber =
        mode == '1' || mode == '3' ? 'pleasenumber.MP3' : 'pleasenumber.MP3';

    if (mode == '4') {
      await player.play(AssetSource('sound/LOAS/$pleaseNumber'));
      await Future.delayed(Duration(milliseconds: 1500));
    } else {
      await player.play(AssetSource('sound/$language/$pleaseNumber'));
      await Future.delayed(Duration(milliseconds: 1500));
    }

    int consecutiveZeros = 0;
    for (int i = 0; i < numberString.length; i++) {
      String digit = numberString[i];
      await player.play(AssetSource('sound/$language/$digit.mp3'));

      await player.onPlayerStateChanged.firstWhere(
        (state) => state == PlayerState.completed,
      );

      if (digit == '0' &&
          i < numberString.length - 1 &&
          numberString[i + 1] == '0') {
        consecutiveZeros++;
        if (consecutiveZeros > 1) {
          await Future.delayed(Duration(milliseconds: 500));
        }
      } else {
        consecutiveZeros = 0;
      }
      if (i < numberString.length - 1 && digit == numberString[i + 1]) {
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
    _focusNode.requestFocus();
    _textController.clear();
    await player.onPlayerStateChanged
        .firstWhere((state) => state == PlayerState.completed);
    _stopFlash();
    await player.dispose();
  }

  // จัดการการกระพริบสี
  Timer? _flashTimer;
  int _flashCount = 0;
  bool _isGreen = true;
  void _startFlash() {
    _flashCount = 0; // รีเซ็ตจำนวนครั้งที่กระพริบ
    _flashTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _isGreen = !_isGreen; // เปลี่ยนสีของ Text
        _flashCount++; // เพิ่มจำนวนครั้งที่กระพริบ
        if (_flashCount >= 8) {
          _flashTimer?.cancel(); // หยุดการกระพริบเมื่อกระพริบครบ 4 ครั้ง
        }
      });
    });
  }

  void _stopFlash() {
    _flashTimer?.cancel();
    setState(() {
      _isGreen = true;
    });
  }

// จัดการรูปภาพ
  Timer? _timer; // ประกาศตัวแปร _timer
  final Duration _changeImageDuration = const Duration(seconds: 10);
  final PageController _pageController = PageController();
  final List<String> imageList = [
    'assets/images/logoHawkerChan.png',
    'assets/images/hawkerpromotion.jpg',
    'assets/images/hawkerpromotion.jpg',
  ];

// ฟังก์ชันเริ่มต้น Timer
  void startTimer() {
    Timer.periodic(_changeImageDuration, (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page?.toInt() ?? 0) + 1;
        if (nextPage >= imageList.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration:
              const Duration(milliseconds: 1000), // กำหนดความเร็วในการเลื่อน
          curve:
              Curves.easeInOut, // กำหนดโครงร่างการเริ่มและสิ้นสุดของการเลื่อน
        );
      }
    });
  }

// ฟังก์ชันหยุด Timer
  void stopTimer() {
    _timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    _stopFlash();
    super.dispose();
    stopTimer();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      },
      child: Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: const Color.fromARGB(235, 241, 248, 120),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Opacity(
                          opacity: 1,
                          child: TextField(
                            controller: _textController,
                            onChanged: (value) {
                              _checkvalue(value);
                            },
                            onSubmitted: _handleSubmit,
                            autofocus: true,
                            focusNode: _focusNode,
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(
                                fontSize: 1.0,
                                color: Color.fromARGB(235, 0, 0, 0),
                              ),
                              // border: InputBorder.none,
                            ),
                            inputFormatters: [
                              // LengthLimitingTextInputFormatter(3),
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d+-.*/]')),
                            ],
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(
                          height: screenSize.height *
                              0.20, // 20% ของความสูงของหน้าจอ
                          // color: Colors.yellow,
                          child: Image.asset(
                            'assets/images/logoHawkerChan.png', // ที่อยู่ของรูปภาพในโฟลเดอร์ assets
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 9, 105, 14),
                        minimumSize: Size(
                            screenSize.width * 0.3, screenSize.height * 0.07),
                      ),
                      child: Text(
                        'NEXT QUEUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenSize.width * 0.015,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical:
                              0.0), // เพิ่ม padding เพื่อลดพื้นที่รอบๆข้อความ
                      child: Text(
                        _value.substring(0, 3),
                        style: TextStyle(
                          color: _isGreen
                              ? Color.fromARGB(255, 128, 0, 32)
                              : Color.fromARGB(255, 255, 230, 0),
                          fontSize: screenSize.height *
                              0.32, // ลดขนาด font ของข้อความ
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 9, 105, 14),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size(
                              screenSize.width * 0.3, screenSize.height * 0.07),
                        ),
                      ),
                      child: Text(
                        'PAST QUEUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenSize.width * 0.015,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.05),
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              // ใช้ Expanded เพื่อให้ Column มีขนาดที่เหมาะสม
                              child: SizedBox(
                                width: screenSize.width * 0.4,
                                child: Column(
                                  children:
                                      _splitListIntoColumns(_valueList_last, 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imageList.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.black,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(
                        imageList[index],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _splitListIntoColumns(List<String> list, int columns) {
    final Size screenSize = MediaQuery.of(context).size;
    List<Widget> columnWidgets = [];
    List<Widget> rowWidgets = [];

    for (int i = 0; i < list.length; i++) {
      rowWidgets.add(
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  list[i].toString(),
                  style: TextStyle(
                    color: Color.fromARGB(255, 128, 0, 32),
                    fontSize: screenSize.height * 0.06,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if ((i + 1) % columns == 0 || i == list.length - 1) {
        columnWidgets.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: rowWidgets,
          ),
        );
        rowWidgets = [];
      }

      // เมื่อเต็ม 6 คอลัมน์หรือเมื่อมาถึงสุดท้ายของรายการ
      if (rowWidgets.length == columns || i == list.length - 1) {
        columnWidgets.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: rowWidgets,
          ),
        );
        rowWidgets = [];
      }
    }

    return columnWidgets;
  }

  // เล่นเสียง
  // Future<void> _playSound_old(String value) async {
  //   // ตรวจสอบว่ามาจากโหมดไหน
  //   final player = AudioPlayer();
  //   var box = await Hive.openBox('ModeSounds');
  //   // ignore: unused_local_variable
  //   var values = box.values.toList();
  //   var mode = box.values.first;
  //   if (mode == '1') {
  //     player.play(AssetSource('sound/bell.mp3'));
  //     await Future.delayed(const Duration(milliseconds: 1500));
  //     player.play(AssetSource('sound/EN/pleasenumber.MP3'));
  //     await Future.delayed(const Duration(milliseconds: 1500));
  //     for (int i = 0; i < value.length; i++) {
  //       final player = AudioPlayer();
  //       player.play(AssetSource('sound/EN/${value[i]}.MP3'));
  //       await Future.delayed(const Duration(milliseconds: 700));
  //     }
  //   } else if (mode == '2') {
  //     player.play(AssetSource('sound/LOAS/pleasenumber.MP3'));
  //     await Future.delayed(const Duration(milliseconds: 1500));
  //     for (int i = 0; i < value.length; i++) {
  //       final player = AudioPlayer();
  //       player.play(AssetSource('sound/LOAS/${value[i]}.MP3'));
  //       await Future.delayed(const Duration(milliseconds: 700));
  //     }
  //   } else if (mode == '3') {
  //     player.play(AssetSource('sound/EN/pleasenumber.MP3'));
  //     await Future.delayed(const Duration(milliseconds: 1500));
  //     for (int i = 0; i < value.length; i++) {
  //       final player = AudioPlayer();
  //       player.play(AssetSource('sound/EN/${value[i]}.MP3'));
  //       await Future.delayed(const Duration(milliseconds: 700));
  //     }
  //   } else if (mode == '4') {
  //     player.play(AssetSource('sound/LOAS/pleasenumber.MP3'));
  //     await Future.delayed(const Duration(milliseconds: 1500));
  //     for (int i = 0; i < value.length; i++) {
  //       final player = AudioPlayer();
  //       player.play(AssetSource('sound/LOAS/${value[i]}.MP3'));
  //       await Future.delayed(const Duration(milliseconds: 700));
  //     }
  //     await Future.delayed(const Duration(milliseconds: 500));
  //     player.play(AssetSource('sound/EN/pleasenumber.MP3'));
  //     await Future.delayed(const Duration(milliseconds: 1500));
  //     for (int i = 0; i < value.length; i++) {
  //       final player = AudioPlayer();
  //       player.play(AssetSource('sound/EN/${value[i]}.MP3'));
  //       await Future.delayed(const Duration(milliseconds: 700));
  //     }
  //   }
  // }

  // Future<void> _handleSubmit(String value) async {
  //   if (_isPlaying) {
  //     return;
  //   }
  //   if (value == '+') {
  //     int currentValue = int.parse(_value);
  //     _value = (currentValue + 1).toString().padLeft(0, '0');
  //     _startFlash();
  //   } else if (value.startsWith('-')) {
  //     String numberPart = value.substring(1);
  //     if (numberPart.isNotEmpty && int.tryParse(numberPart) != null) {
  //       _valueList_last.remove(numberPart);
  //       _focusNode.requestFocus();
  //       _textController.clear();
  //     } else {
  //       _focusNode.requestFocus();
  //       _textController.clear();
  //     }
  //   } else if (value == '*') {
  //     _focusNode.requestFocus();
  //     _textController.clear();
  //   } else if (int.tryParse(value) != null) {
  //     _value = value.toString().padLeft(0, '0');
  //     _startFlash();
  //     await _playSound(_value);
  //   } else if (value == '.') {
  //     int currentValue = int.parse(_value);
  //     _value = (currentValue).toString().padLeft(0, '0');
  //     _startFlash();
  //     await _playSound(_value);
  //   } else if (value == '---') {
  //     _valueList.clear();
  //     _value = '000';
  //   } else if (value.startsWith('***')) {
  //     String numberPart = value.substring(3);
  //     if (numberPart.isNotEmpty && int.tryParse(numberPart) != null) {
  //       // ฟังก์ชั่นเปลี่ยนโหมด
  //       await _addToHive(numberPart);
  //       var box = await Hive.openBox('ModeSounds');
  //       // ignore: unused_local_variable
  //       var values = box.values.toList();
  //       var mode = box.values.first;
  //       if (mode == '1') {
  //         showDialog(
  //           // ignore: use_build_context_synchronously
  //           context: context,
  //           builder: (BuildContext context) {
  //             const duration = Duration(seconds: 2);
  //             Timer(duration, () {
  //               Navigator.of(context).pop();
  //             });
  //             return const AlertDialog(
  //               title: Text(
  //                 'กำลังทำการเปลี่ยนโหมด เสียงกระดิ่ง',
  //                 style: TextStyle(fontSize: 35),
  //                 textAlign: TextAlign
  //                     .center, // จัดให้ข้อความตรงกลาง, // กำหนดขนาดฟ้อนต์ให้ใหญ่
  //               ),
  //               content: Text(
  //                 'Changing mode, bell sound |  ປ່ຽນໂໝດ, ສຽງກະດິ່ງ',
  //                 style: TextStyle(fontSize: 35),
  //                 textAlign: TextAlign
  //                     .center, // จัดให้ข้อความตรงกลาง, // กำหนดขนาดฟ้อนต์ให้ใหญ่
  //               ),
  //             );
  //           },
  //         );
  //       } else if (mode == '2') {
  //         showDialog(
  //           // ignore: use_build_context_synchronously
  //           context: context,
  //           builder: (BuildContext context) {
  //             const duration = Duration(seconds: 2);
  //             Timer(duration, () {
  //               Navigator.of(context).pop();
  //             });
  //             return const AlertDialog(
  //               title: Text(
  //                 'กำลังทำการเปลี่ยนโหมด เล่นเสียง LOAS',
  //                 style: TextStyle(fontSize: 35),
  //                 textAlign: TextAlign
  //                     .center, // จัดให้ข้อความตรงกลาง, // กำหนดขนาดฟ้อนต์ให้ใหญ่
  //               ),
  //               content: Text(
  //                 'Changing mode, LOAS sound |  ປ່ຽນໂໝດ, ຫຼິ້ນສຽງ ປະເທດລາວ',
  //                 style: TextStyle(fontSize: 35),
  //                 textAlign: TextAlign
  //                     .center, // จัดให้ข้อความตรงกลาง, // กำหนดขนาดฟ้อนต์ให้ใหญ่
  //               ),
  //             );
  //           },
  //         );
  //       } else if (mode == '3') {
  //         showDialog(
  //           // ignore: use_build_context_synchronously
  //           context: context,
  //           builder: (BuildContext context) {
  //             const duration = Duration(seconds: 2);
  //             Timer(duration, () {
  //               Navigator.of(context).pop();
  //             });
  //             return const AlertDialog(
  //               title: Text(
  //                 'กำลังทำการเปลี่ยนโหมด เล่นเสียง EN',
  //                 style: TextStyle(fontSize: 35),
  //                 textAlign: TextAlign
  //                     .center, // จัดให้ข้อความตรงกลาง, // กำหนดขนาดฟ้อนต์ให้ใหญ่
  //               ),
  //               content: Text(
  //                 'Changing mode, EN sound |  ປ່ຽນໂໝດ, ຫຼິ້ນສຽງ ພາສາອັງກິດ',
  //                 style: TextStyle(fontSize: 35),
  //                 textAlign: TextAlign
  //                     .center, // จัดให้ข้อความตรงกลาง, // กำหนดขนาดฟ้อนต์ให้ใหญ่
  //               ),
  //             );
  //           },
  //         );
  //       } else if (mode == '4') {
  //         showDialog(
  //           // ignore: use_build_context_synchronously
  //           context: context,
  //           builder: (BuildContext context) {
  //             const duration = Duration(seconds: 2);
  //             Timer(duration, () {
  //               Navigator.of(context).pop();
  //             });
  //             return const AlertDialog(
  //               title: Text(
  //                 'กำลังทำการเปลี่ยนโหมด เล่นเสียง LOAS + EN',
  //                 style: TextStyle(fontSize: 35),
  //                 textAlign: TextAlign
  //                     .center, // จัดให้ข้อความตรงกลาง, // กำหนดขนาดฟ้อนต์ให้ใหญ่
  //               ),
  //               content: Text(
  //                 'Changing mode, LOAS sound + EN sound | ປ່ຽນໂໝດ, ຫຼິ້ນສຽງ ປະເທດລາວ + ຫຼິ້ນສຽງ ພາສາອັງກິດ',
  //                 style: TextStyle(fontSize: 35),
  //                 textAlign: TextAlign
  //                     .center, // จัดให้ข้อความตรงกลาง, // กำหนดขนาดฟ้อนต์ให้ใหญ่
  //               ),
  //             );
  //           },
  //         );
  //       }
  //     } else {
  //       _focusNode.requestFocus();
  //       _textController.clear();
  //     }
  //   } else if (RegExp(r'[^\d+-.*/]').hasMatch(value)) {
  //     _focusNode.requestFocus();
  //     _textController.clear();
  //   } else if (value.startsWith('/')) {
  //     String numberPart = value.substring(1);
  //     if (numberPart.isNotEmpty && int.tryParse(numberPart) != null) {
  //       setState(() {
  //         _isPlaying = false;
  //         if (numberPart != '000' || numberPart != '00' || numberPart != '0') {
  //           _valueList.add(numberPart);
  //           if (_valueList.isNotEmpty) {
  //             if (!_valueList_last.contains(numberPart)) {
  //               _valueList_last.add(numberPart);
  //               if (_valueList_last.length > 6) {
  //                 _valueList_last.removeLast();
  //               }
  //             }
  //           }
  //         }
  //       });
  //     } else {
  //       _focusNode.requestFocus();
  //       _textController.clear();
  //     }
  //   } else {
  //     _focusNode.requestFocus();
  //     _textController.clear();
  //   }
  //   _focusNode.requestFocus();
  //   _textController.clear();
  // }

  Future<void> _checkvalue(String value) async {
    if (_isPlaying) {
      return;
    }
    if (value == '.') {
      if (_value == '000' || _value == '00' || _value == '0') {
        _focusNode.requestFocus();
        _textController.clear();
      } else {
        int currentValue = int.parse(_value);
        _value = (currentValue).toString().padLeft(0, '0');
        _startFlash();
        await _playSound(_value);
        _stopFlash();
      }
    } else if (value == '+') {
      _handlePlus();
    }
  }
}
