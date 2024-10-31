import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _value = '000';
  String? _errorLoadingImage;
  bool _isPlaying = false;
  final List<String> _valueList = [];
  int maxDigits = 3;
  final List<String> _valueList_last = [];
  List<File> imageList = [];
  Timer? _timer;
  final Duration _changeImageDuration = const Duration(seconds: 10);
  final PageController _pageController = PageController();
  Timer? _flashTimer;
  int _flashCount = 0;
  bool _isGreen = true;

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
        body: Container(
          color: Color.fromARGB(235, 0, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    FilteringTextInputFormatter.allow(RegExp(r'[\d+-.*/]')),
                  ],
                  maxLines: 1,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 1.0,
                    vertical: 0.0), // เพิ่ม padding เพื่อลดพื้นที่รอบๆข้อความ
                child: Text(
                  _value.substring(0, 3),
                  style: TextStyle(
                    color: _isGreen
                        ? Color.fromARGB(255, 255, 255, 255)
                        : Color.fromARGB(255, 218, 41, 28),
                    fontSize:
                        screenSize.height * 0.65, // ลดขนาด font ของข้อความ
                    fontWeight: FontWeight.bold,
                    letterSpacing: 100.0,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        // Expanded(
        //   flex: 3,
        //   child: PageView.builder(
        //     controller: _pageController,
        //     itemCount: imageList.length,
        //     itemBuilder: (context, index) {
        //       return Container(
        //         color: Colors.black,
        //         child: FittedBox(
        //           fit: BoxFit.fitWidth,
        //           child: Image.file(
        //             imageList[index],
        //           ),
        //           // child: Image.asset(
        //           //   imageList[index],
        //           // ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
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
                    color: Color.fromARGB(255, 218, 41, 28),
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
      // _playSound(value);
    } else if (value == '---') {
      _handleReset();
    } else if (value.startsWith('***')) {
      _handleModeChange(value);
    } else if (RegExp(r'[^\d+-.*/]').hasMatch(value)) {
      _handleInvalidCharacter();
    } else if ((value.startsWith('/'))) {
      _handleSlashValue(value);
    } else {
      _handleOtherCases();
    }
  }

  void _handleNumericValue(String value) async {
    print("รับค่าตัวเลขตรงๆ");
    _value = value.toString().padLeft(3, '0');
    _startFlash();
    _playSound(_value);
    _stopFlash();
    _focusNode.requestFocus();
    _textController.clear();
  }

  void _handleOtherCases() {
    _focusNode.requestFocus();
    _textController.clear();
  }

  void _handleSlashValue(String value) {
    if (value == '/') {
      String numberPart = _value.substring(0);
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
    } else {
      _handleSlash(value);
    }
  }

  void _handleSlash(String value) {
    print("เรียกแล้วไม่มา");
    String numberPart = value.substring(1);
    if (numberPart.isNotEmpty && int.tryParse(numberPart) != null) {
      while (numberPart.length < 3) {
        numberPart = '0' + numberPart;
      }
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

  void _handleInvalidCharacter() {
    _focusNode.requestFocus();
    _textController.clear();
  }

  void _handleReset() {
    print("ลบออกหมดทุกอย่าง");
    setState(() {
      _valueList.clear();
      _valueList_last.clear();
      // _value = '000';
    });
    _focusNode.requestFocus();
    _textController.clear();
  }

  void _handleMultiply() {
    print("เคลียค่า");
    setState(() {
      _value = '000';
    });
    _focusNode.requestFocus();
    _textController.clear();
  }

  void _handleMinus(String value) {
    print("เอาออกจาก array");
    String numberPart = value.substring(1);
    if (numberPart.isNotEmpty && int.tryParse(numberPart) != null) {
      // เติม 0 นำหน้าให้ numberPart ถ้าจำนวนหลักไม่ถึง 3
      while (numberPart.length < 3) {
        numberPart = '0' + numberPart;
      }
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

  void _playSound(String value) async {
    var box = await Hive.openBox('ModeSounds');
    var values = box.values.toList();
    var mode = box.values.first;
    final trimmedString = value.toString();
    final numberString = trimmedString.replaceAll(RegExp('^0+'), '');
    if (mode == '0') {
      await _audioPlayer.play(AssetSource('sound/bell.mp3'));
    } else if (mode == '1') {
      await _audioPlayer.play(AssetSource('sound/TH/queuenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1200));
      for (int i = 0; i < numberString.length; i++) {
        await _audioPlayer.play(AssetSource('sound/TH/${numberString[i]}.MP3'));
        if (i + 1 < numberString.length &&
            numberString[i] == numberString[i + 1]) {
          // ถ้าตัวเลขปัจจุบันซ้ำกับตัวเลขถัดไป
          await _audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 650));
        }
      }
    } else if (mode == '2') {
      await _audioPlayer.play(AssetSource('sound/EN/queuenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1200));
      for (int i = 0; i < numberString.length; i++) {
        await _audioPlayer.play(AssetSource('sound/EN/${numberString[i]}.MP3'));
        if (i + 1 < numberString.length &&
            numberString[i] == numberString[i + 1]) {
          // ถ้าตัวเลขปัจจุบันซ้ำกับตัวเลขถัดไป
          await _audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 650));
        }
      }
    } else if (mode == '3') {
      await _audioPlayer.play(AssetSource('sound/CN/queuenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1200));
      for (int i = 0; i < numberString.length; i++) {
        await _audioPlayer.play(AssetSource('sound/CN/${numberString[i]}.MP3'));
        if (i + 1 < numberString.length &&
            numberString[i] == numberString[i + 1]) {
          // ถ้าตัวเลขปัจจุบันซ้ำกับตัวเลขถัดไป
          await _audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 650));
        }
      }
    } else if (mode == '4') {
      await _audioPlayer.play(AssetSource('sound/KR/queuenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1200));
      for (int i = 0; i < numberString.length; i++) {
        await _audioPlayer.play(AssetSource('sound/KR/${numberString[i]}.MP3'));
        if (i + 1 < numberString.length &&
            numberString[i] == numberString[i + 1]) {
          // ถ้าตัวเลขปัจจุบันซ้ำกับตัวเลขถัดไป
          await _audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 650));
        }
      }
    } else if (mode == '5') {
      await _audioPlayer.play(AssetSource('sound/TH/queuenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1200));
      for (int i = 0; i < numberString.length; i++) {
        await _audioPlayer.play(AssetSource('sound/TH/${numberString[i]}.MP3'));
        if (i + 1 < numberString.length &&
            numberString[i] == numberString[i + 1]) {
          // ถ้าตัวเลขปัจจุบันซ้ำกับตัวเลขถัดไป
          await _audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 650));
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
      await _audioPlayer.play(AssetSource('sound/EN/queuenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1200));
      for (int i = 0; i < numberString.length; i++) {
        await _audioPlayer.play(AssetSource('sound/EN/${numberString[i]}.MP3'));
        if (i + 1 < numberString.length &&
            numberString[i] == numberString[i + 1]) {
          // ถ้าตัวเลขปัจจุบันซ้ำกับตัวเลขถัดไป
          await _audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 650));
        }
      }
    } else if (mode == '6') {
      await _audioPlayer.play(AssetSource('sound/TH/queuenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1200));
      for (int i = 0; i < numberString.length; i++) {
        await _audioPlayer.play(AssetSource('sound/TH/${numberString[i]}.MP3'));
        if (i + 1 < numberString.length &&
            numberString[i] == numberString[i + 1]) {
          // ถ้าตัวเลขปัจจุบันซ้ำกับตัวเลขถัดไป
          await _audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 650));
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
      await _audioPlayer.play(AssetSource('sound/EN/queuenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1200));
      for (int i = 0; i < numberString.length; i++) {
        await _audioPlayer.play(AssetSource('sound/EN/${numberString[i]}.MP3'));
        if (i + 1 < numberString.length &&
            numberString[i] == numberString[i + 1]) {
          // ถ้าตัวเลขปัจจุบันซ้ำกับตัวเลขถัดไป
          await _audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 650));
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
      await _audioPlayer.play(AssetSource('sound/CN/queuenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1200));
      for (int i = 0; i < numberString.length; i++) {
        await _audioPlayer.play(AssetSource('sound/CN/${numberString[i]}.MP3'));
        if (i + 1 < numberString.length &&
            numberString[i] == numberString[i + 1]) {
          // ถ้าตัวเลขปัจจุบันซ้ำกับตัวเลขถัดไป
          await _audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 650));
        }
      }
    } else if (mode == '7') {
      await _audioPlayer.play(AssetSource('sound/TH/queuenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1200));
      for (int i = 0; i < numberString.length; i++) {
        await _audioPlayer.play(AssetSource('sound/TH/${numberString[i]}.MP3'));
        if (i + 1 < numberString.length &&
            numberString[i] == numberString[i + 1]) {
          // ถ้าตัวเลขปัจจุบันซ้ำกับตัวเลขถัดไป
          await _audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 650));
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
      await _audioPlayer.play(AssetSource('sound/EN/queuenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1200));
      for (int i = 0; i < numberString.length; i++) {
        await _audioPlayer.play(AssetSource('sound/EN/${numberString[i]}.MP3'));
        if (i + 1 < numberString.length &&
            numberString[i] == numberString[i + 1]) {
          // ถ้าตัวเลขปัจจุบันซ้ำกับตัวเลขถัดไป
          await _audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 650));
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
      await _audioPlayer.play(AssetSource('sound/KR/queuenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1200));
      for (int i = 0; i < numberString.length; i++) {
        await _audioPlayer.play(AssetSource('sound/KR/${numberString[i]}.MP3'));
        if (i + 1 < numberString.length &&
            numberString[i] == numberString[i + 1]) {
          // ถ้าตัวเลขปัจจุบันซ้ำกับตัวเลขถัดไป
          await _audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 650));
        }
      }
    } else if (mode == '8') {
      await _audioPlayer.play(AssetSource('sound/TH/queuenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1200));
      for (int i = 0; i < numberString.length; i++) {
        await _audioPlayer.play(AssetSource('sound/TH/${numberString[i]}.MP3'));
        if (i + 1 < numberString.length &&
            numberString[i] == numberString[i + 1]) {
          // ถ้าตัวเลขปัจจุบันซ้ำกับตัวเลขถัดไป
          await _audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 650));
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
      await _audioPlayer.play(AssetSource('sound/EN/queuenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1200));
      for (int i = 0; i < numberString.length; i++) {
        await _audioPlayer.play(AssetSource('sound/EN/${numberString[i]}.MP3'));
        if (i + 1 < numberString.length &&
            numberString[i] == numberString[i + 1]) {
          // ถ้าตัวเลขปัจจุบันซ้ำกับตัวเลขถัดไป
          await _audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 650));
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
      await _audioPlayer.play(AssetSource('sound/CN/queuenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1200));
      for (int i = 0; i < numberString.length; i++) {
        await _audioPlayer.play(AssetSource('sound/CN/${numberString[i]}.MP3'));
        if (i + 1 < numberString.length &&
            numberString[i] == numberString[i + 1]) {
          // ถ้าตัวเลขปัจจุบันซ้ำกับตัวเลขถัดไป
          await _audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 650));
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
      await _audioPlayer.play(AssetSource('sound/KR/queuenumber.MP3'));
      await Future.delayed(const Duration(milliseconds: 1200));
      for (int i = 0; i < numberString.length; i++) {
        await _audioPlayer.play(AssetSource('sound/KR/${numberString[i]}.MP3'));
        if (i + 1 < numberString.length &&
            numberString[i] == numberString[i + 1]) {
          // ถ้าตัวเลขปัจจุบันซ้ำกับตัวเลขถัดไป
          await _audioPlayer.onPlayerStateChanged.firstWhere(
            (state) => state == PlayerState.completed,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 650));
        }
      }
    } else {
      await _audioPlayer.play(AssetSource('sound/bell.mp3'));
    }
  }

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

  Future<void> _addToHive(String mode) async {
    var box = await Hive.openBox('ModeSounds');
    await box.put('mode', mode);
    await box.close();
    setState(() {});
  }

  void _showModeChangeDialog(String mode) {
    String title, content;
    switch (mode) {
      case '0':
        title = 'MODE 0 : Calling voice - BELL';
        // content = 'Changing mode, bell sound |  ປ່ຽນໂໝດ, ສຽງກະດິ່ງ';
        content = '';
        break;
      case '1':
        title = 'MODE 1 : Calling voice - THAI';
        // content = 'Changing mode, bell sound |  ປ່ຽນໂໝດ, ສຽງກະດິ່ງ';
        content = '';
        break;
      case '2':
        title = 'MODE 2 : Calling voice - ENGLISH';
        // content = 'Changing mode, LOAS sound |  ປ່ຽນໂໝດ, ຫຼິ້ນສຽງ ປະເທດລາວ';
        content = '';
        break;
      case '3':
        title = 'MODE 3 : Calling voice - CHINA';
        // content = 'Changing mode, EN sound |  ປ່ຽນໂໝດ, ຫຼິ້ນສຽງ ພາສາອັງກິດ';
        content = '';
        break;
      case '4':
        title = 'MODE 4 : Calling voice - KOREA';
        // content =
        //     'Changing mode, LOAS sound + EN sound | ປ່ຽນໂໝດ, ຫຼິ້ນສຽງ ປະເທດລາວ + ຫຼິ້ນສຽງ ພາສາອັງກິດ';
        content = '';
        break;
      case '5':
        title = 'MODE 5 : Calling voice - THAI + ENGLISH';
        // content =
        //     'Changing mode, LOAS sound + EN sound | ປ່ຽນໂໝດ, ຫຼິ້ນສຽງ ປະເທດລາວ + ຫຼິ້ນສຽງ ພາສາອັງກິດ';
        content = '';
        break;
      case '6':
        title = 'MODE 6 : Calling voice - THAI + ENGLISH + CHINA';
        // content =
        //     'Changing mode, LOAS sound + EN sound | ປ່ຽນໂໝດ, ຫຼິ້ນສຽງ ປະເທດລາວ + ຫຼິ້ນສຽງ ພາສາອັງກິດ';
        content = '';
        break;
      case '7':
        title = 'MODE 7 : Calling voice - THAI + ENGLISH + KOREA';
        // content =
        //     'Changing mode, LOAS sound + EN sound | ປ່ຽນໂໝດ, ຫຼິ້ນສຽງ ປະເທດລາວ + ຫຼິ້ນສຽງ ພາສາອັງກິດ';
        content = '';
        break;
      case '8':
        title = 'MODE 8 : Calling voice - THAI + ENGLISH + CHINA + KOREA';
        // content =
        //     'Changing mode, LOAS sound + EN sound | ປ່ຽນໂໝດ, ຫຼິ້ນສຽງ ປະເທດລາວ + ຫຼິ້ນສຽງ ພາສາອັງກິດ';
        content = '';
        break;
      default:
        title = 'Bell';
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
            style: TextStyle(fontSize: 35),
            textAlign: TextAlign.center,
          ),
          // content: Text(
          //   content,
          //   style: TextStyle(fontSize: 35),
          //   textAlign: TextAlign.center,
          // ),
        );
      },
    );
    _focusNode.requestFocus();
    _textController.clear();
  }

  Future<void> loadImagesFromDrive() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await _requestExternalStoragePermission();
    }
    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      throw 'External storage directory not found';
    }
    String usbPath =
        // '${externalDir.parent.parent.parent.parent.parent.parent.path}/CF09-E67B/images';
        '${externalDir.parent.parent.parent.parent.parent.parent.path}/DB1D-7C56/images';
    // '${externalDir.parent.parent.parent.parent.parent.parent.path}/2627-6E53/images';
    if (usbPath == null) {
      throw 'USB path is null';
    }
    Directory usbDir = Directory(usbPath);
    if (!usbDir.existsSync()) {
      throw 'USB directory does not exist';
    }

    List<FileSystemEntity> files = usbDir.listSync();

    if (files.isEmpty) {
      throw 'No files found in USB directory';
    }
    List<File> imageFiles = files.whereType<File>().toList();
    if (imageFiles.isEmpty) {
      throw 'No image files found in USB directory';
    }
    setState(() {
      imageList = imageFiles;
    });
  }

  Future<void> _requestExternalStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
    } else {
      setState(() {
        _errorLoadingImage = 'Permission denied for storage';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _requestExternalStoragePermission();
    // loadImagesFromDrive();
    // startTimer();
  }

  void startTimer() {
    const Duration interval =
        Duration(seconds: 10); // กำหนดช่วงเวลาที่ต้องการให้ทำงานทุก 10 วินาที
    _timer = Timer.periodic(interval, (Timer timer) {
      loadImagesFromDrive(); // เรียก loadImagesFromDrive() ทุก 10 วินาที
    });
    Timer.periodic(_changeImageDuration, (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page?.toInt() ?? 0) + 1;
        if (nextPage >= imageList.length) {
          nextPage = 0;
        }
        setState(() {
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void _checkvalue(String value) async {
    if (_isPlaying) {
      return;
    }
    if (value == '.') {
      if (_value == '000' || _value == '00' || _value == '0') {
        _focusNode.requestFocus();
        _textController.clear();
      } else {
        int currentValue = int.parse(_value);
        _value = (currentValue).toString().padLeft(3, '0');
        _startFlash();
        _playSound(_value);
        _stopFlash();
      }
    } else if (value == '+') {
      _handlePlus();
    }
  }

  void _handlePlus() async {
    int currentValue = int.parse(_value);
    _value = (currentValue + 1).toString().padLeft(3, '0');
    _startFlash();
    _playSound(_value);
    _stopFlash();
    _focusNode.requestFocus();
    _textController.clear();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    _stopFlash();
    super.dispose();
    stopTimer();
  }
}
