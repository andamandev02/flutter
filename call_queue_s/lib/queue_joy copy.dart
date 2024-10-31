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
  // ignore: non_constant_identifier_names
  final List<String> _valueList_last = [];
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

  Future<void> _handleSubmit(String value) async {
    if (_isPlaying) {
      return;
    }

    if (value == '+') {
      _handlePlus();
    } else if (value.startsWith('-')) {
      _handleMinus(value);
    } else if (value == '*') {
      _handleMultiply();
    } else if (int.tryParse(value) != null) {
      await _handleNumericValue(value);
    } else if (value == '.') {
      _handleDot();
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

  void _handlePlus() {
    int currentValue = int.parse(_value);
    _value = (currentValue + 1).toString().padLeft(0, '0');
    _startFlash();
    _focusNode.requestFocus();
    _textController.clear();
  }

  void _handleMinus(String value) {
    String numberPart = value.substring(1);
    if (numberPart.isNotEmpty && int.tryParse(numberPart) != null) {
      _valueList_last.remove(numberPart);
      _focusNode.requestFocus();
      _textController.clear();
    } else {
      _focusNode.requestFocus();
      _textController.clear();
    }
  }

  void _handleMultiply() {
    _focusNode.requestFocus();
    _textController.clear();
  }

  Future<void> _handleNumericValue(String value) async {
    _value = value.toString().padLeft(0, '0');
    _startFlash();
    await _playSound(_value);
    _focusNode.requestFocus();
    _textController.clear();
  }

  void _handleDot() {
    int currentValue = int.parse(_value);
    _value = (currentValue).toString().padLeft(0, '0');
    _startFlash();
    _focusNode.requestFocus();
    _textController.clear();
  }

  void _handleReset() {
    _valueList.clear();
    _valueList_last.clear();
    setState(() {
      _value = '000';
    });
    _focusNode.requestFocus();
    _textController.clear();
  }

  void _handleModeChange(String value) async {
    String numberPart = value.substring(3);
    if (numberPart.isNotEmpty && int.tryParse(numberPart) != null) {
      // ฟังก์ชั่นเปลี่ยนโหมด
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
                _valueList_last.removeLast();
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

  Future<void> checkvalue(String value) async {
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
        _focusNode.requestFocus();
        _textController.clear();
      }
    } else if (value == '+') {
      int currentValue = int.parse(_value);
      _value = (currentValue + 1).toString().padLeft(0, '0');
      _startFlash();
      await _playSound(_value);
      _stopFlash();
      _focusNode.requestFocus();
      _textController.clear();
    }
  }

  Future<void> _addToHive(String mode) async {
    var box = await Hive.openBox('ModeSounds');
    await box.put('mode', mode);
    await box.close();
    setState(() {});
  }

  // เล่นเสียง
  Future<void> _playSound(String value) async {
    // ตรวจสอบว่ามาจากโหมดไหน
    final player = AudioPlayer();
    var box = await Hive.openBox('ModeSounds');
    // ignore: unused_local_variable
    var values = box.values.toList();
    var mode = box.values.first;
    if (mode == '1') {
      player.play(AssetSource('sound/bell.mp3'));
      await Future.delayed(const Duration(milliseconds: 1500));
      player.play(AssetSource('sound/EN/pleasenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1500));
      for (int i = 0; i < value.length; i++) {
        final player = AudioPlayer();
        player.play(AssetSource('sound/EN/${value[i]}.MP3'));
        await Future.delayed(const Duration(milliseconds: 700));
      }
    } else if (mode == '2') {
      player.play(AssetSource('sound/LOAS/pleasenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1500));
      for (int i = 0; i < value.length; i++) {
        final player = AudioPlayer();
        player.play(AssetSource('sound/LOAS/${value[i]}.MP3'));
        await Future.delayed(const Duration(milliseconds: 700));
      }
    } else if (mode == '3') {
      player.play(AssetSource('sound/EN/pleasenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1500));
      for (int i = 0; i < value.length; i++) {
        final player = AudioPlayer();
        player.play(AssetSource('sound/EN/${value[i]}.MP3'));
        await Future.delayed(const Duration(milliseconds: 700));
      }
    } else if (mode == '4') {
      player.play(AssetSource('sound/LOAS/pleasenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1500));
      for (int i = 0; i < value.length; i++) {
        final player = AudioPlayer();
        player.play(AssetSource('sound/LOAS/${value[i]}.MP3'));
        await Future.delayed(const Duration(milliseconds: 700));
      }
      await Future.delayed(const Duration(milliseconds: 800));
      player.play(AssetSource('sound/EN/pleasenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1500));
      for (int i = 0; i < value.length; i++) {
        final player = AudioPlayer();
        player.play(AssetSource('sound/EN/${value[i]}.MP3'));
        await Future.delayed(const Duration(milliseconds: 700));
      }
    }
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
                              checkvalue(value);
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, // เพิ่มบรรทัดนี้
                      children: [
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 9, 105, 14),
                            minimumSize: Size(screenSize.width * 0.3,
                                screenSize.height * 0.07),
                          ),
                          child: Text(
                            'NEXT QUEUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenSize.width * 0.015,
                            ),
                          ),
                        ),
                        Text(
                          _value,
                          style: TextStyle(
                            color: _isGreen
                                ? const Color.fromARGB(255, 9, 105, 14)
                                : Colors.red,
                            fontSize: screenSize.height * 0.35,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 9, 105, 14),
                            ),
                            minimumSize: MaterialStateProperty.all<Size>(
                              Size(screenSize.width * 0.3,
                                  screenSize.height * 0.07),
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
                      ],
                    ),
                    SizedBox(height: screenSize.height * 0.01),
                    const Divider(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: _splitListIntoColumns(_valueList_last, 2),
                      ),
                    ),
                    // Column(
                    //   children: _valueList_last.length >= 2
                    //       ? _valueList_last
                    //           .sublist(_valueList_last.length - 2)
                    //           .map((item) => Column(
                    //                 children: [
                    //                   Text(
                    //                     item,
                    //                     style: TextStyle(
                    //                       color: Colors.black,
                    //                       fontSize: screenSize.height * 0.05,
                    //                     ),
                    //                   ),
                    //                   const Divider(),
                    //                 ],
                    //               ))
                    //           .toList()
                    //           .reversed
                    //           .toList() // สลับลำดับของรายการให้รายการล่าสุดอยู่บนสุด
                    //       : _valueList_last
                    //           .map((item) => Column(
                    //                 children: [
                    //                   Text(
                    //                     item,
                    //                     style: TextStyle(
                    //                       color: Colors.black,
                    //                       fontSize: screenSize.height * 0.05,
                    //                     ),
                    //                   ),
                    //                   // const Divider(),
                    //                 ],
                    //               ))
                    //           .toList()
                    //           .reversed
                    //           .toList(), // สลับลำดับของรายการให้รายการล่าสุดอยู่บนสุด
                    // ),
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
            alignment: Alignment.centerLeft,
            child: Text(
              list[i].toString(),
              style: TextStyle(
                color: Colors.black,
                fontSize: screenSize.height * 0.06,
              ),
            ),
          ),
        ),
      );

      if ((i + 1) % columns == 0 || i == list.length - 1) {
        columnWidgets.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // เพิ่มบรรทัดนี้
            children: rowWidgets,
          ),
        );
        rowWidgets = [];
      }

      // เมื่อเต็ม 6 คอลัมน์หรือเมื่อมาถึงสุดท้ายของรายการ
      if (rowWidgets.length == columns || i == list.length - 1) {
        columnWidgets.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // เพิ่มบรรทัดนี้
            children: rowWidgets,
          ),
        );
        rowWidgets = [];
      }
    }

    return columnWidgets;
  }
}
