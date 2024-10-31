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
  // final AudioPlayer player = AudioPlayer();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _value = '000';
  String? _errorLoadingImage;
  bool _isPlaying = false;
  final List<String> _valueList = [];
  int maxDigits = 3;
  final List<String> _valueList_last = [];
  List<File> imageList = [];
  final Duration _changeImageDuration = const Duration(seconds: 10);
  final PageController _pageController = PageController();
  Timer? _flashTimer;
  int _flashCount = 0;
  bool _isGreen = true;

  Color _textColor = Colors.white;
  Timer? _timer;

  void _startFlash() {
    _flashCount = 0;
    _flashTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      setState(() {
        _isGreen = !_isGreen;
        _flashCount++;
        if (_flashCount >= 6) {
          _flashTimer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double baseFontSize = screenSize.height * 0.065;
    final double fontSize = baseFontSize * 11.5;
    final double letterSpacing = screenSize.width * 0.05;

    return GestureDetector(
      onTap: () {
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              // child: FittedBox(
              //   fit: BoxFit.contain,
              child: Text(
                _value.substring(0, 3),
                style: TextStyle(
                  // color: Colors.white,
                  color: _textColor,
                  fontSize: fontSize * 1.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: letterSpacing,
                  fontFamily: 'DIGITAL',
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
            // ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1),
              child: Opacity(
                opacity: 0,
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
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d+-.*/]')),
                  ],
                  maxLines: 1,
                  // enabled: _isFieldEnabled,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isFieldEnabled = true;

  Future<void> _handleSubmit(String value) async {
    if (_isPlaying) {
      return;
    }
    setState(() {
      _isFieldEnabled = false;
    });
    if (value == '*') {
      _handleMultiply();
    } else if (int.tryParse(value) != null) {
      _handleNumericValue(value);
    } else if (value.startsWith('***')) {
      _handleModeChange(value);
    } else if (RegExp(r'[^\d+-.*/]').hasMatch(value)) {
      _handleInvalidCharacter();
    } else {
      _handleOtherCases();
    }
  }

  void _handleNumericValue(String value) async {
    _value = value.toString().padLeft(3, '0');
    _playSound(_value);
    _focusNode.requestFocus();
    _textController.clear();
  }

  void _handleOtherCases() {
    _focusNode.requestFocus();
    _textController.clear();
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

  // void _playSound(String value) async {
  //   try {
  //     var box = await Hive.openBox('ModeSounds');
  //     var values = box.values.toList();
  //     var mode = box.values.first;
  //     final trimmedString = value.toString();
  //     final numberString = trimmedString.replaceAll(RegExp('^0+'), '');

  //     Future<void> playSequence(String languageCode) async {
  //       await _audioPlayer
  //           .play(AssetSource('sound/$languageCode/queuenumber.mp3'));
  //       await Future.delayed(const Duration(milliseconds: 1200));
  //       for (int i = 0; i < numberString.length; i++) {
  //         if (languageCode == 'TH') {
  //           await _audioPlayer.play(
  //               AssetSource('sound/$languageCode/${numberString[i]}.MP3'));
  //         } else {
  //           await _audioPlayer.play(
  //               AssetSource('sound/$languageCode/${numberString[i]}.mp3'));
  //         }

  //         if (i + 1 < numberString.length &&
  //             numberString[i] == numberString[i + 1]) {
  //           try {
  //             await _audioPlayer.onPlayerStateChanged.firstWhere(
  //               (state) => state == PlayerState.completed,
  //             );
  //           } catch (e) {
  //             print('Error waiting for player state: $e');
  //           }
  //         } else {
  //           await Future.delayed(const Duration(milliseconds: 650));
  //         }
  //       }
  //     }

  //     switch (mode) {
  //       case '0':
  //         await _audioPlayer.play(AssetSource('sound/bell.mp3'));
  //         break;
  //       case '1':
  //         await playSequence('TH');
  //         break;
  //       case '2':
  //         await playSequence('EN');
  //         break;
  //       case '3':
  //         await playSequence('CN');
  //         break;
  //       case '4':
  //         await playSequence('KR');
  //         break;
  //       case '5':
  //         await playSequence('TH');
  //         await Future.delayed(const Duration(milliseconds: 100));
  //         await playSequence('EN');
  //         break;
  //       case '6':
  //         await playSequence('TH');
  //         await Future.delayed(const Duration(milliseconds: 100));
  //         await playSequence('EN');
  //         await Future.delayed(const Duration(milliseconds: 100));
  //         await playSequence('CN');
  //         break;
  //       case '7':
  //         await playSequence('TH');
  //         await Future.delayed(const Duration(milliseconds: 100));
  //         await playSequence('EN');
  //         await Future.delayed(const Duration(milliseconds: 100));
  //         await playSequence('KR');
  //         break;
  //       case '8':
  //         await playSequence('TH');
  //         await Future.delayed(const Duration(milliseconds: 100));
  //         await playSequence('EN');
  //         await Future.delayed(const Duration(milliseconds: 100));
  //         await playSequence('CN');
  //         await Future.delayed(const Duration(milliseconds: 100));
  //         await playSequence('KR');
  //         break;
  //       default:
  //         await _audioPlayer.play(AssetSource('sound/bell.mp3'));
  //     }
  //   } catch (e) {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text(
  //             '$e',
  //             style: TextStyle(fontSize: 50),
  //             textAlign: TextAlign.center,
  //           ),
  //         );
  //       },
  //     );
  //     print('Error playing sound: $e');
  //   }
  // }

  void _playSound(String value) async {
    try {
      final player = AudioPlayer();
      _timer?.cancel();
      var box = await Hive.openBox('ModeSounds');
      var values = box.values.toList();
      var mode = box.values.first;
      final trimmedString = value.toString();
      final numberString = trimmedString.replaceAll(RegExp('^0+'), '');
      print(numberString);
      try {
        _startBlinking();

        Future<void> playNumberSound(String number, String lang) async {
          for (int i = 0; i < number.length; i++) {
            await Future.delayed(const Duration(milliseconds: 550));
            await player.play(AssetSource('sound/$lang/${number[i]}.mp3'));
            if (i + 1 < number.length && number[i] == number[i + 1]) {
              await player.onPlayerStateChanged.firstWhere(
                (state) => state == PlayerState.completed,
                orElse: () => PlayerState.completed,
              );
            } else {
              await Future.delayed(const Duration(milliseconds: 650));
            }
          }
        }

        if (mode == '0') {
          await player.play(AssetSource('sound/bell.mp3'));
        } else if (mode == '1') {
          await player.play(AssetSource('sound/TH/queuenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          await playNumberSound(numberString, 'TH');
        } else if (mode == '2') {
          await player.play(AssetSource('sound/EN/queuenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          await playNumberSound(numberString, 'EN');
        } else if (mode == '3') {
          await player.play(AssetSource('sound/CN/queuenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          await playNumberSound(numberString, 'CN');
        } else if (mode == '4') {
          await player.play(AssetSource('sound/KR/queuenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          await playNumberSound(numberString, 'KR');
        } else if (mode == '5') {
          await player.play(AssetSource('sound/TH/queuenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          await playNumberSound(numberString, 'TH');
          await Future.delayed(const Duration(milliseconds: 100));
          await player.play(AssetSource('sound/EN/queuenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          await playNumberSound(numberString, 'EN');
        } else if (mode == '6') {
          await player.play(AssetSource('sound/TH/queuenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          await playNumberSound(numberString, 'TH');
          await Future.delayed(const Duration(milliseconds: 100));
          await player.play(AssetSource('sound/EN/queuenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          await playNumberSound(numberString, 'EN');
          await Future.delayed(const Duration(milliseconds: 100));
          await player.play(AssetSource('sound/CN/queuenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          await playNumberSound(numberString, 'CN');
        } else if (mode == '7') {
          await player.play(AssetSource('sound/TH/queuenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          await playNumberSound(numberString, 'TH');
          await Future.delayed(const Duration(milliseconds: 100));
          await player.play(AssetSource('sound/EN/queuenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          await playNumberSound(numberString, 'EN');
          await Future.delayed(const Duration(milliseconds: 100));
          await player.play(AssetSource('sound/KR/queuenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          await playNumberSound(numberString, 'KR');
        } else if (mode == '8') {
          await player.play(AssetSource('sound/TH/queuenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          await playNumberSound(numberString, 'TH');
          await Future.delayed(const Duration(milliseconds: 100));
          await player.play(AssetSource('sound/EN/queuenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          await playNumberSound(numberString, 'EN');
          await Future.delayed(const Duration(milliseconds: 100));
          await player.play(AssetSource('sound/CN/queuenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          await playNumberSound(numberString, 'CN');
          await Future.delayed(const Duration(milliseconds: 100));
          await player.play(AssetSource('sound/KR/queuenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          await playNumberSound(numberString, 'KR');
        } else {
          await player.play(AssetSource('sound/bell.mp3'));
        }
      } catch (e) {
        print("Error playing sound: $e");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Error playing sound: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } finally {
        _timer?.cancel();
        _isFieldEnabled = true;
      }
    } catch (e) {
      print("Error opening Hive box: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error opening Hive box: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
    _timer?.cancel();
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
            style: TextStyle(fontSize: 50),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
    _focusNode.requestFocus();
    _textController.clear();
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
  }

  void _startBlinking() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _textColor = _textColor == Colors.white ? Colors.red : Colors.white;
      });
    });
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
        _playSound(_value);
        _focusNode.requestFocus();
        _textController.clear();
      }
    } else if (value == '+') {
      _handlePlus();
    }
  }

  void _handlePlus() async {
    int currentValue = int.parse(_value);
    _value = (currentValue + 1).toString().padLeft(3, '0');
    _playSound(_value);
    _focusNode.requestFocus();
    _textController.clear();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    _stopFlash();
    super.dispose();
  }
}
