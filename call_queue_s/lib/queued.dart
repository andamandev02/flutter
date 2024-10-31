import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';

class QueueScreenD extends StatefulWidget {
  const QueueScreenD({Key? key}) : super(key: key);

  @override
  State<QueueScreenD> createState() => _QueueScreenDState();
}

class _QueueScreenDState extends State<QueueScreenD> {
// จัดการข้อความ
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _value = '0000';
  bool _isPlaying = false;
  List<String> _valueList = [];
  List<String> _valueList_last = [];
  void _handleSubmit(String value) {
    if (_isPlaying) {
      return;
    }
    setState(() {
      if (value == '+') {
        // ตรวจสอบว่ารับค่า + หรือไม่
        int currentValue = int.parse(_value);
        _value = (currentValue + 1).toString();
        _startFlash();
        _playSound(_value);
      } else if (int.tryParse(value) != null) {
        // ตรวจสอบว่ารับค่าเป็นตัวเลขหรือไม่
        _value = value.toString();
        _startFlash();
        _playSound(_value);
      } else if (value == '.') {
        // ตรวจสอบว่ารับค่า .
        int currentValue = int.parse(_value);
        _value = (currentValue).toString();
        _startFlash();
        _playSound(_value);
      } else if (value == '---') {
        _valueList.clear();
        _value = '0';
      } else if (value == '*') {
        _valueList.clear();
        _value = '0';
      } else if (value == '--') {
        if (_valueList.isNotEmpty) {
          String _value = _valueList[_valueList.length - 3];
          _startFlash();
          _playSound(_value);
        }
      } else if (RegExp(r'[^\d+-.*]').hasMatch(value)) {
        _focusNode.requestFocus();
        _textController.clear();
      }
      _isPlaying =
          true; // ตั้งค่า _isPlaying เป็น true ที่นี่เนื่องจากจะเริ่มการเล่นเสียงแล้ว
    });
    // ไม่ต้องใช้ async ที่นี่
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        if (_value != '000') {
          _valueList.add(_value);
          if (_valueList.isNotEmpty) {
            if (!_valueList_last.contains(_value)) {
              _valueList_last.add(_value);
              if (_valueList_last.length > 2) {
                _valueList_last.removeLast();
              }
            }
          }
        }
        _isPlaying = false;
        _focusNode.requestFocus();
        _textController.clear();
      });
    });
  }

  // เล่นเสียง
  void _playSound(String value) async {
    // final player = AudioPlayer();
    // final numberString = value.toString();
    // await player.play(AssetSource('sounds/bell.mp3'));
    // await Future.delayed(const Duration(milliseconds: 800));

    // await player.play(AssetSource('sounds/number.mp3'));
    // await Future.delayed(const Duration(milliseconds: 800));

    // for (int i = 0; i < numberString.length; i++) {
    //   String digit = numberString[i];
    //   await player.play(AssetSource('sounds/$digit.mp3'));
    //   await Future.delayed(const Duration(milliseconds: 700));
    // }
    // await player.dispose();

    final player = AudioPlayer();
    final numberString = value.toString();
    await player.play(AssetSource('sounds/bell.mp3'));
    await Future.delayed(Duration(milliseconds: 800));
    await player.play(AssetSource('sounds/number.mp3'));
    await Future.delayed(Duration(milliseconds: 800));
    int consecutiveZeros = 0;
    for (int i = 0; i < numberString.length; i++) {
      String digit = numberString[i];
      await player.play(AssetSource('sounds/$digit.mp3'));

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
        consecutiveZeros = 0; // รีเซ็ตตัวแปรเมื่อตัวเลขถัดไปไม่ใช่ศูนย์
      }
      if (i < numberString.length - 1 && digit == numberString[i + 1]) {
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
    await player.onPlayerStateChanged
        .firstWhere((state) => state == PlayerState.completed);
    _stopFlash();
    // ปิดเสียง
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
    double screenWidth = MediaQuery.of(context).size.width;
    double initialFontSize = 650.0;
    double fontSize = screenWidth * 0.45;
    return MaterialApp(
      home: Scaffold(
        body: GestureDetector(
          onTap: () {
            if (!_focusNode.hasFocus) {
              _focusNode.requestFocus();
            }
          },
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.all(0),
                  color: Colors.black,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: 0,
                        child: TextField(
                          controller: _textController,
                          onSubmitted: _handleSubmit,
                          autofocus: true,
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(
                              fontSize: 1.0,
                              color: Color.fromARGB(235, 0, 0, 0),
                            ),
                            border: InputBorder.none,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[\d+-.*]')),
                            LengthLimitingTextInputFormatter(4),
                          ],
                          maxLines: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: _value,
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      color: _isGreen
                                          ? const Color.fromARGB(
                                              255, 255, 255, 255)
                                          : Colors.red,
                                      letterSpacing: 50.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'DIGITAL',
                                    ),
                                  )
                                ],
                              ),
                            ),
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
    );
  }
}
