import 'package:audioplayers/audioplayers.dart';
import 'package:monitor_2/display1.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'controller.dart';
import 'ip.dart';

class DisplayScreen2 extends StatefulWidget {
  const DisplayScreen2({super.key});

  @override
  State<DisplayScreen2> createState() => _DisplayScreen2State();
}

class _DisplayScreen2State extends State<DisplayScreen2> {
  String numberCounterFirst = '';
  String firstDigit = '';
  String latestValue = '';
  String latestValueForLeft = '';
  String latestValueForRight = '';
  String latestValueForLeft1 = '';
  String latestValueForRight1 = '';
  List<List<String>> newArray = [];
  List<List<String>> historyArray = [];
  bool isPlaying = false;
  int blinkCount = 0; // ตัวแปรสำหรับเก็บจำนวนการกระพริบ
  bool isRed = false;
  bool isDisplayedValueRed = false;

  void Displaywipwap() async {
    await Future.delayed(Duration(milliseconds: 800));
    setState(() {
      isDisplayedValueRed = !isDisplayedValueRed;
    });

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

  void playQueue(List<List<String>> queue) async {
    if (!isPlaying && queue.isNotEmpty) {
      isPlaying = true;
      List<String> item = queue[0];
      String key = item[0];
      String value = item[1];
      if (key == '1') {
        latestValueForLeft1 = value;
        addToHistory("1", latestValueForLeft1);
      }

      if (key == '2') {
        latestValueForRight1 = value;
        addToHistory("2", latestValueForRight1);
      }
      Displaywipwap();
      await soundVolume(key, value);
      queue.removeAt(0);
      isPlaying = false;
      playQueue(queue);
    }
  }

  void addToHistory(String key, String value) {
    historyArray.add([key, value]);
    if (historyArray.length > 5) {
      historyArray.removeAt(0); // ลบค่าเก่าสุด
    }
    print(historyArray);
  }

  // Future<void> soundVolume(String key, String queueNumber) async {
  //   final player = AudioPlayer();
  //   await player.play(AssetSource('sounds/number.mp3'));
  //   await Future.delayed(const Duration(milliseconds: 800));
  //   for (int i = 0; i < queueNumber.length; i++) {
  //     String character = queueNumber[i];
  //     if (character.isNotEmpty && character != ' ') {
  //       await player.play(AssetSource('sounds/$character.mp3'));
  //       await Future.delayed(const Duration(milliseconds: 1200));
  //     }
  //   }
  //   await player.play(AssetSource('sounds/pleasegotocounteranumber.mp3'));
  //   await Future.delayed(const Duration(milliseconds: 2500));

  //   String numberCounter = key;
  //   await player.play(AssetSource('sounds/$numberCounter.mp3'));
  //   // await Future.delayed(const Duration(milliseconds: 800));
  // }

  Future<void> soundVolume(String key, String queueNumber) async {
    final player = AudioPlayer();
    final numberString = queueNumber.toString();
    // เล่นเสียงตัวแรก
    await player.play(AssetSource('sounds/number.mp3'));
    await Future.delayed(Duration(milliseconds: 1500));
    int consecutiveZeros =
        0; // เพิ่มตัวแปรเพื่อตรวจสอบเฉพาะการเล่นเสียงเมื่อตัวเลขถัดไปเป็นศูนย์
    for (int i = 0; i < numberString.length; i++) {
      String digit = numberString[i];
      await player.play(AssetSource('sounds/$digit.mp3'));
      await player.onPlayerStateChanged.firstWhere(
        (state) => state == PlayerState.completed,
      ); // รอให้เสียงเล่นเสร็จสิ้นก่อนที่จะดำเนินการต่อ
      if (digit == '0' &&
          i < numberString.length - 1 &&
          numberString[i + 1] == '0') {
        consecutiveZeros++;
        if (consecutiveZeros > 1) {
          // รอเวลาเพิ่มเติมหลังจากเล่นเสียงซ้ำ
          await Future.delayed(Duration(milliseconds: 800));
        }
      } else {
        consecutiveZeros = 0; // รีเซ็ตตัวแปรเมื่อตัวเลขถัดไปไม่ใช่ศูนย์
      }
      // เช็คว่าตัวเลขถัดไปซ้ำกันหรือไม่ ถ้าไม่ซ้ำกันให้เล่นเสียงอีกครั้ง
      if (i < numberString.length - 1 && digit == numberString[i + 1]) {
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
    await player.play(AssetSource('sounds/pleasegotocounteranumber.mp3'));
    await Future.delayed(const Duration(milliseconds: 2500));

    String numberCounter = key;
    await player.play(AssetSource('sounds/$numberCounter.mp3'));
    // รอจนเสร็จสิ้นการเล่นเสียง
    await player.onPlayerStateChanged
        .firstWhere((state) => state == PlayerState.completed);
    // ปิดเสียง
    await player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double textSize =
        0.12 * MediaQuery.of(context).size.width; // กำหนดขนาดตัวอักษรอัตโนมัติ

    return GestureDetector(
      onDoubleTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const IPScreen()),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.black, // พื้นหลังสีดำสำหรับ MyWidget
        body: GetBuilder<ServerController>(
          init: ServerController(),
          builder: (controller) {
            List<String> serverLogStrings =
                controller.serverLogs.map((e) => e).toList();
            Map<String, List<String>> groupedLogs = {};
            for (String log in serverLogStrings) {
              String firstCharacter = log.substring(0, 1);
              if (!groupedLogs.containsKey(firstCharacter)) {
                groupedLogs[firstCharacter] = [];
              }
              groupedLogs[firstCharacter]?.add(log);
            }
            List<List<String>> separatedLogs = groupedLogs.values.toList();
            separatedLogs.removeWhere((list) => list.isEmpty);
            if (separatedLogs.isNotEmpty && separatedLogs[0].isNotEmpty) {
              // ดึงมาบางส่วน
              String firstSeparatedValue = separatedLogs[0][0];
              // ดึงมาเฉพาะตัวแรก
              String firstSeparatedValueOk = firstSeparatedValue[0][0];
              // ตัดตัวแรกของข้อความออก
              String firstSeparatedValueYeah = firstSeparatedValue.substring(1);
              if (firstSeparatedValueOk == '1') {
                latestValueForLeft = firstSeparatedValueYeah;
                newArray.add(["1", latestValueForLeft]);
                controller.serverLogs.clear();
              } else if (firstSeparatedValueOk == '2') {
                latestValueForRight = firstSeparatedValueYeah;
                newArray.add(["2", latestValueForRight]);
                controller.serverLogs.clear();
              }
            } else {
              // print("separatedLogs ไม่มีสมาชิก");
            }

            newArray.sort((a, b) => a[0].compareTo(b[0]));
            playQueue(newArray);

            return Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // จัดตำแหน่งอิสระระหว่าง children
                    children: [
                      Flexible(
                        flex: 1,
                        child: Text(
                          "Counter Service  Display 2",
                          style: TextStyle(
                            color: Colors.yellow,
                            // color: Colors.yellow,
                            fontSize: 0.04 * MediaQuery.of(context).size.width,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 5,
                        child: Container(
                          color: const Color.fromARGB(255, 6, 55, 95),
                          margin: EdgeInsets.all(
                              0.005 * MediaQuery.of(context).size.width),
                          padding: EdgeInsets.all(
                              0.005 * MediaQuery.of(context).size.width),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Column(
                                  children: [
                                    Text(
                                      "Counter 1",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 0.04 *
                                            MediaQuery.of(context).size.width,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Column(
                                  children: [
                                    Text(
                                      latestValueForLeft1,
                                      style: TextStyle(
                                        color: Colors.yellow,
                                        fontSize: textSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 5,
                        child: Container(
                          color: const Color.fromARGB(255, 6, 55, 95),
                          margin: EdgeInsets.all(
                              0.005 * MediaQuery.of(context).size.width),
                          padding: EdgeInsets.all(
                              0.005 * MediaQuery.of(context).size.width),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Column(
                                  children: [
                                    Text(
                                      "Counter 2",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 0.04 *
                                            MediaQuery.of(context).size.width,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Column(
                                  children: [
                                    Text(
                                      latestValueForRight1,
                                      style: TextStyle(
                                        // color: Colors.yellow,
                                        color: isDisplayedValueRed
                                            ? Colors.red
                                            : Colors.yellow,
                                        fontSize: textSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // จัดตำแหน่งอิสระระหว่าง children
                    children: [
                      Flexible(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                              ),
                              Text(
                                "Servered Tokens",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      0.04 * MediaQuery.of(context).size.width,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(), // Spacer จะจัดวางไอคอนไปทางขวาสุด
                              IconButton(
                                onPressed: () {
                                  // เพิ่มโค้ดที่ต้องการให้ทำงานเมื่อปุ่มถูกกดที่นี่
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DisplayScreen1()));
                                },
                                icon: Icon(
                                    Icons.camera), // เลือกไอคอนตามความเหมาะสม
                                color: Colors.white, // สีไอคอน
                              ),
                            ],
                          )),
                      Flexible(
                        flex: 10,
                        child: Container(
                          margin: EdgeInsets.all(
                              0.005 * MediaQuery.of(context).size.width),
                          padding: EdgeInsets.all(
                              0.005 * MediaQuery.of(context).size.width),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromARGB(255, 6, 55, 95),
                              width: 0.01 * MediaQuery.of(context).size.width,
                            ),
                          ),
                          width: 0.5 * MediaQuery.of(context).size.width,
                          child: Column(
                            children: historyArray.reversed
                                .map((item) => Text(
                                      "${item[1]} Counter ${item[0]} ",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 0.06 *
                                            MediaQuery.of(context).size.width,
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
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