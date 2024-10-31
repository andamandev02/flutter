import 'dart:async';

import 'package:call_queue_4_3_13_2024/player_extension.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});
  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  final _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  String? displayedValue = '00';
  bool isDisplayedValueRed = false;
  bool isTextFieldEnabled = true;
  int blinkCount = 0; // ตัวแปรสำหรับเก็บจำนวนการกระพริบ
  bool _isNumeric(String value) {
    final numericRegex = RegExp(r'^[0-9]+$');
    return numericRegex.hasMatch(value);
  }

  String? clickstart = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  void setup() {
    setState(() {
      _textEditingController.clear();
      isTextFieldEnabled = true;
      clickstart = '';

      ///new api
      // scheduleMicrotask(() {
      //   ///  _focusNode.requestFocus()
      // });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    });
  }

  void _checkNumericValue(String value) async {
    if (_isNumeric(value)) {
      // setup();
    } else {
      if (value == '/') {
        clickstart = value;
        setState(() {
          isTextFieldEnabled = false;
        });
        setState(() {
          _textEditingController.clear();
          isTextFieldEnabled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _focusNode.requestFocus();
          });
        });
      } else if (clickstart == '/') {
        if (value == ' ' || value == '\n' || value == '\r') {
          setup();
        } else if (_isNumeric(value)) {
          setup();
        } else if (value == '+') {
          setState(() {
            isTextFieldEnabled = false;
          });
          if (displayedValue == '00') {
            displayedValue = '1';
            soundvolumn(displayedValue!);
            Displaywipwap();
            await Future.delayed(Duration(milliseconds: 4000));
            setup();
          } else {
            int numericValue = int.tryParse(displayedValue!) ?? 0;
            if (numericValue == 9999) {
              displayedValue = '1';
              Displaywipwap();
              soundvolumn(displayedValue!);
              await Future.delayed(Duration(milliseconds: 4000));
              setup();
              return;
            }
            numericValue = (numericValue + 1) % 1000;
            displayedValue = numericValue.toString().padLeft(2, '0');
            Displaywipwap();
            soundvolumn(displayedValue!);
            await Future.delayed(Duration(milliseconds: 4000));
            setup();
          }
        } else if (value == '*') {
          setState(() {
            displayedValue = '00';
          });
          setup();
        } else if (value == '-') {
          setState(() {
            isTextFieldEnabled = false;
          });
          if (displayedValue == '00') {
            setup();
          } else {
            int numericValue = int.tryParse(displayedValue!) ?? 0;
            if (numericValue == 0) {
              setup();
              return;
            }
            numericValue = (numericValue - 1) % 1000;
            displayedValue = numericValue.toString().padLeft(2, '0');
            if (displayedValue == '00') {
              setup();
              return;
            }
            Displaywipwap();
            soundvolumn(displayedValue!);
            await Future.delayed(Duration(milliseconds: 4000));
            setup();
          }
        } else {
          setup();
        }
      } else if (value == '.') {
        if (displayedValue == '00') {
          setup();
          return;
        }
        clickstart = '/';
        setState(() {
          isTextFieldEnabled = false;
        });
        if (displayedValue != '00') {
          setState(() {
            _onSubmitted(displayedValue!);
          });
        }
      } else {
        setup();
      }
    }
  }

  void _onSubmitted(String value) async {
    if (clickstart != '/') {
      setup();
      return;
    }
    if (value == ' ' || value == '\n' || value == '\r') {
      setup();
      return;
    }
    if (_isNumeric(value)) {
      // ตรวจสอบว่า value มีตัวเลขหลักเดียวหรือไม่
      if (value.length == 1) {
        // ถ้ามีเพียงตัวเลขหลักเดียว ก็ไม่ต้องเติม 0 นำหน้า
        setState(() {
          isTextFieldEnabled = false;
          displayedValue = value;
          Displaywipwap();
          soundvolumn(displayedValue!);
        });
      } else {
        // ถ้ามีมากกว่าหรือเท่ากับ 2 หลัก ให้เติม 0 นำหน้าตามปกติ
        // ตัดเลข 0 ที่อยู่ด้านหน้าของค่า value
        value = value.replaceFirst(RegExp('^0+'), '');
        if (value.isEmpty) {
          // ถ้าหลังจากตัด 0 ออกแล้ว value ว่างเปล่า ก็ให้กลับไป setup()
          setup();
          return;
        }
        setState(() {
          isTextFieldEnabled = false;
          displayedValue = value.padLeft(2, '0');
          Displaywipwap();
          soundvolumn(displayedValue!);
        });
      }
    }
    await Future.delayed(Duration(milliseconds: 4200));
    setup();
  }

  void soundvolumn(String number) async {
    final player = AudioPlayer();
    final numberString = number.toString();
    await player.addAssets(asset: 'sounds/Bell.mp3');
    await Future.delayed(Duration(milliseconds: 1000));
    await player.addAssets(asset: 'sounds/number.mp3');
    // await player.setAsset('sounds/number.mp3');
    await Future.delayed(Duration(milliseconds: 1000));
    int consecutiveZeros = 0;
    await player.play();
    player.processingStateStream.listen((processingState) async {
      if (processingState == ProcessingState.completed) {
        for (int i = 0; i < numberString.length; i++) {
          String digit = numberString[i];
          await player.addAssets(asset: 'sounds/$digit.mp3');
          // await player.setAsset('sounds/$digit.mp3');
          if (digit == '0' &&
              i < numberString.length - 1 &&
              numberString[i + 1] == '0') {
            consecutiveZeros++;
            if (consecutiveZeros > 1) {
              await Future.delayed(Duration(milliseconds: 800));
            }
          } else {
            consecutiveZeros = 0;
          }
          if (i < numberString.length - 1 && digit == numberString[i + 1]) {
            await Future.delayed(Duration(milliseconds: 100));
          }
        }
        await player.dispose();
      }
      await player.play();
    });
  }

  void Displaywipwap() async {
    await Future.delayed(Duration(milliseconds: 800));
    setState(() {
      isDisplayedValueRed = !isDisplayedValueRed;
    });
    if (int.parse(displayedValue!) > 100) {
      for (int i = 0; i < 3; i++) {
        await Future.delayed(Duration(milliseconds: 800));
        setState(() {
          isDisplayedValueRed = !isDisplayedValueRed;
        });
        await Future.delayed(Duration(milliseconds: 800));
        setState(() {
          isDisplayedValueRed = !isDisplayedValueRed;
        });
      }
    } else if (int.parse(displayedValue!) < 100 &&
        int.parse(displayedValue!) >= 10) {
      for (int i = 0; i < 3; i++) {
        await Future.delayed(Duration(milliseconds: 800));
        setState(() {
          isDisplayedValueRed = !isDisplayedValueRed;
        });
        await Future.delayed(Duration(milliseconds: 800));
        setState(() {
          isDisplayedValueRed = !isDisplayedValueRed;
        });
      }
    } else {
      for (int i = 0; i < 3; i++) {
        await Future.delayed(Duration(milliseconds: 800));
        setState(() {
          isDisplayedValueRed = !isDisplayedValueRed;
        });
        await Future.delayed(Duration(milliseconds: 800));
        setState(() {
          isDisplayedValueRed = !isDisplayedValueRed;
        });
      }
    }

    if (blinkCount > 3) {
      setState(() {
        isDisplayedValueRed = false;
      });
    } else {
      setState(() {
        isDisplayedValueRed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ModalRoute.of(context)?.addScopedWillPopCallback(() {
        return Future.value(false);
      });
    });

    return MaterialApp(
      home: Scaffold(
        body: GestureDetector(
          onTap: () {
            // ignore: unnecessary_null_comparison
            if (_focusNode != null) {
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: 1,
                        child: RawKeyboardListener(
                          focusNode: FocusNode(),
                          onKey: (event) {
                            if (event.logicalKey == LogicalKeyboardKey.space) {
                              _onSubmitted(_textEditingController.text);
                            }
                          },
                          child: TextField(
                            enabled: isTextFieldEnabled,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(4),
                            ],
                            focusNode: _focusNode,
                            controller: _textEditingController,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                _checkNumericValue(value);
                              }
                            },
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                _onSubmitted(value);
                              } else {
                                _onSubmitted(_textEditingController.text);
                              }
                            },
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
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
                                  for (int i = 0;
                                      i < (displayedValue?.length ?? 0);
                                      i++)
                                    TextSpan(
                                      text: displayedValue![i],
                                      style: TextStyle(
                                        fontSize: screenWidth *
                                            0.45, // ปรับขนาดตามต้องการ
                                        color: isDisplayedValueRed
                                            ? Colors.red
                                            : Colors.white,
                                        letterSpacing: screenWidth *
                                            0.18, // ปรับตามต้องการ
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
