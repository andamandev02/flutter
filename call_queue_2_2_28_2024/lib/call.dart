import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});
  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  FocusNode _focusNode = FocusNode();
  TextEditingController _textEditingController = TextEditingController();
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
            displayedValue = '01';
            soundvolumn(displayedValue!);
            Displaywipwap();
            await Future.delayed(Duration(milliseconds: 4000));
            setup();
          } else {
            int numericValue = int.tryParse(displayedValue!) ?? 0;
            if (numericValue == 99) {
              displayedValue = '01';
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
      // setState(() {
      // isTextFieldEnabled = false;
      // });
      // await Future.delayed(Duration(milliseconds: 100));
      // setup();
      // return;
    }
    if (value == ' ' || value == '\n' || value == '\r') {
      setup();
    }
    if (_isNumeric(value)) {
      if (value == '0' || value == '00') {
      } else {
        setState(() {
          isTextFieldEnabled = false;
        });
        setState(() {
          displayedValue = value.padLeft(2, '0');
          Displaywipwap();
          soundvolumn(displayedValue!);
        });
      }
    }
    await Future.delayed(Duration(milliseconds: 4200));
    setup();
  }

  // void soundvolumn(String number) async {
  //   final player = AudioPlayer();
  //   final numberString = number.toString();

  //   // เล่นเสียงตัวแรก
  //   await player.play(AssetSource('sounds/number.mp3'));

  //   await Future.delayed(Duration(milliseconds: 1500));

  //   int consecutiveZeros =
  //       0; // เพิ่มตัวแปรเพื่อตรวจสอบเฉพาะการเล่นเสียงเมื่อตัวเลขถัดไปเป็นศูนย์

  //   for (int i = 0; i < numberString.length; i++) {
  //     String digit = numberString[i];
  //     await player.play(AssetSource('sounds/$digit.mp3'));

  //     await player.onPlayerStateChanged.firstWhere(
  //       (state) => state == PlayerState.completed,
  //     ); // รอให้เสียงเล่นเสร็จสิ้นก่อนที่จะดำเนินการต่อ

  //     if (digit == '0' &&
  //         i < numberString.length - 1 &&
  //         numberString[i + 1] == '0') {
  //       consecutiveZeros++;
  //       if (consecutiveZeros > 1) {
  //         // รอเวลาเพิ่มเติมหลังจากเล่นเสียงซ้ำ
  //         await Future.delayed(Duration(milliseconds: 800));
  //       }
  //     } else {
  //       consecutiveZeros = 0; // รีเซ็ตตัวแปรเมื่อตัวเลขถัดไปไม่ใช่ศูนย์
  //     }

  //     // เช็คว่าตัวเลขถัดไปซ้ำกันหรือไม่ ถ้าไม่ซ้ำกันให้เล่นเสียงอีกครั้ง
  //     if (i < numberString.length - 1 && digit == numberString[i + 1]) {
  //       await Future.delayed(Duration(milliseconds: 100));
  //     }
  //   }

  //   // รอจนเสร็จสิ้นการเล่นเสียง
  //   await player.onPlayerStateChanged
  //       .firstWhere((state) => state == PlayerState.completed);

  //   // ปิดเสียง
  //   await player.dispose();
  // }

  void soundvolumn(String number) async {
    final player = AudioPlayer();
    final numberString = number.toString();

    // เล่นไฟล์เสียงตามตัวเลข
    await player.play(AssetSource('voice/$numberString.mp3'));

    // รอจนเสร็จสิ้นการเล่นเสียง
    await player.onPlayerStateChanged
        .firstWhere((state) => state == PlayerState.completed);

    // ปิดเสียง
    await player.dispose();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ModalRoute.of(context)?.addScopedWillPopCallback(() {
        return Future.value(false);
      });
    });

    return MaterialApp(
      home: Scaffold(
        body: GestureDetector(
          onTap: () {
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
                        opacity: 0,
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
                              LengthLimitingTextInputFormatter(2),
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
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double screenWidth =
                                  MediaQuery.of(context).size.width;
                              double fontSize = screenWidth * 0.6;

                              return FittedBox(
                                fit: BoxFit.contain,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      for (int i = 0;
                                          i < (displayedValue?.length ?? 0);
                                          i++)
                                        TextSpan(
                                          text: displayedValue![i],
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.45,
                                            color: isDisplayedValueRed
                                                ? Colors.red
                                                : Colors.white,
                                            letterSpacing: screenWidth * 0.1,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'DIGITAL',
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              );
                            },
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
