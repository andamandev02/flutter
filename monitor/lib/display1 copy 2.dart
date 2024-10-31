// // import 'package:audioplayers/audioplayers.dart';
// // import 'package:get/get.dart';
// // import 'package:monitor/ip.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get_state_manager/src/simple/get_state.dart';
// // import 'package:network_info_plus/network_info_plus.dart';

// // import 'controller.dart';

// // class DisplayScreen1 extends StatefulWidget {
// //   const DisplayScreen1({Key? key}) : super(key: key);

// //   @override
// //   State<DisplayScreen1> createState() => _DisplayScreen1State();
// // }

// // class _DisplayScreen1State extends State<DisplayScreen1> {
// //   String numberCounterFirst = '';
// //   String firstDigit = '';
// //   String latestValue = '';
// //   String latestValueForLeft = '';
// //   String latestValueForRight = '';
// //   String latestValueForLeft1 = '';
// //   String latestValueForRight1 = '';
// //   List<List<String>> newArray = [];
// //   List<List<String>> historyArray = [];
// //   late final ServerController controller;
// //   bool isPlaying = false;
// //   int blinkCount = 0; // ตัวแปรสำหรับเก็บจำนวนการกระพริบ
// //   bool isRed = false;
// //   bool isDisplayedValueRed = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     controller = Get.find<ServerController>();
// //     controller.startOrStopServer();
// //   }

// //   void Displaywipwap() async {
// //     await Future.delayed(Duration(milliseconds: 800));
// //     setState(() {
// //       isDisplayedValueRed = !isDisplayedValueRed;
// //     });

// //     for (int i = 0; i < 3; i++) {
// //       await Future.delayed(Duration(milliseconds: 800));
// //       setState(() {
// //         isDisplayedValueRed = !isDisplayedValueRed;
// //       });
// //       await Future.delayed(Duration(milliseconds: 800));
// //       setState(() {
// //         isDisplayedValueRed = !isDisplayedValueRed;
// //       });
// //     }

// //     if (blinkCount > 3) {
// //       setState(() {
// //         isDisplayedValueRed = false;
// //       });
// //     } else {
// //       setState(() {
// //         isDisplayedValueRed = false;
// //       });
// //     }
// //   }

// //   void flashLatestValueForLeft1() async {
// //     for (int i = 0; i < 3; i++) {
// //       setState(() {
// //         isRed = true; // เปลี่ยนสีเป็นแดง
// //       });
// //       await Future.delayed(
// //           const Duration(milliseconds: 500)); // รอเป็นเวลาสั้นๆ
// //       setState(() {
// //         isRed = false; // เปลี่ยนสีกลับเป็นขาว
// //       });
// //       await Future.delayed(
// //           const Duration(milliseconds: 500)); // รอเป็นเวลาสั้นๆ
// //     }
// //   }

// //   void playQueue(List<List<String>> queue) async {
// //     if (!isPlaying && queue.isNotEmpty) {
// //       isPlaying = true;
// //       List<String> item = queue[0];
// //       String key = item[0];
// //       String value = item[1];
// //       if (key == '1') {
// //         latestValueForLeft1 = value;
// //         addToHistory("1", latestValueForLeft1);
// //         // flashLatestValueForLeft1();
// //         // historyArray.add(["1", latestValueForLeft1]);
// //       }

// //       if (key == '2') {
// //         latestValueForRight1 = value;
// //         addToHistory("2", latestValueForRight1);
// //         // historyArray.add(["2", latestValueForRight1]);
// //       }
// //       Displaywipwap();
// //       await soundVolume(key, value);
// //       queue.removeAt(0);
// //       isPlaying = false;
// //       playQueue(queue);
// //     }
// //   }

// //   void addToHistory(String key, String value) {
// //     historyArray.add([key, value]);
// //     if (historyArray.length > 5) {
// //       historyArray.removeAt(0); // ลบค่าเก่าสุด
// //     }
// //     print(historyArray);
// //   }

// //   Future<void> soundVolume(String key, String queueNumber) async {
// //     final player = AudioPlayer();
// //     final numberString = queueNumber.toString();
// //     // เล่นเสียงตัวแรก
// //     await player.play(AssetSource('sounds/number.mp3'));
// //     await Future.delayed(Duration(milliseconds: 1500));
// //     int consecutiveZeros =
// //         0; // เพิ่มตัวแปรเพื่อตรวจสอบเฉพาะการเล่นเสียงเมื่อตัวเลขถัดไปเป็นศูนย์
// //     for (int i = 0; i < numberString.length; i++) {
// //       String digit = numberString[i];
// //       await player.play(AssetSource('sounds/$digit.mp3'));
// //       await player.onPlayerStateChanged.firstWhere(
// //         (state) => state == PlayerState.completed,
// //       ); // รอให้เสียงเล่นเสร็จสิ้นก่อนที่จะดำเนินการต่อ
// //       if (digit == '0' &&
// //           i < numberString.length - 1 &&
// //           numberString[i + 1] == '0') {
// //         consecutiveZeros++;
// //         if (consecutiveZeros > 1) {
// //           // รอเวลาเพิ่มเติมหลังจากเล่นเสียงซ้ำ
// //           await Future.delayed(Duration(milliseconds: 800));
// //         }
// //       } else {
// //         consecutiveZeros = 0; // รีเซ็ตตัวแปรเมื่อตัวเลขถัดไปไม่ใช่ศูนย์
// //       }
// //       // เช็คว่าตัวเลขถัดไปซ้ำกันหรือไม่ ถ้าไม่ซ้ำกันให้เล่นเสียงอีกครั้ง
// //       if (i < numberString.length - 1 && digit == numberString[i + 1]) {
// //         await Future.delayed(Duration(milliseconds: 100));
// //       }
// //     }
// //     await player.play(AssetSource('sounds/pleasegotocounteranumber.mp3'));
// //     await Future.delayed(const Duration(milliseconds: 2500));

// //     String numberCounter = key;
// //     await player.play(AssetSource('sounds/$numberCounter.mp3'));
// //     // รอจนเสร็จสิ้นการเล่นเสียง
// //     await player.onPlayerStateChanged
// //         .firstWhere((state) => state == PlayerState.completed);
// //     // ปิดเสียง
// //     await player.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     double textSize =
// //         0.12 * MediaQuery.of(context).size.width; // กำหนดขนาดตัวอักษรอัตโนมัติ

// //     return GestureDetector(
// //       onDoubleTap: () {
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(builder: (context) => const IPScreen()),
// //         );
// //       },
// //       child: Scaffold(
// //         backgroundColor: Colors.black, // พื้นหลังสีดำสำหรับ MyWidget
// //         body: GetBuilder<ServerController>(
// //           init: ServerController(),
// //           builder: (controller) {
// //             List<String> serverLogStrings =
// //                 controller.serverLogs.map((e) => e).toList();
// //             Map<String, List<String>> groupedLogs = {};
// //             for (String log in serverLogStrings) {
// //               String firstCharacter = log.substring(0, 1);
// //               firstDigit = firstCharacter;
// //               if (!groupedLogs.containsKey(firstCharacter)) {
// //                 groupedLogs[firstCharacter] = [];
// //               }
// //               groupedLogs[firstCharacter]?.add(log);
// //             }
// //             List<List<String>> separatedLogs = groupedLogs.values.toList();
// //             separatedLogs.removeWhere((list) => list.isEmpty);
// //             if (separatedLogs.isNotEmpty && separatedLogs[0].isNotEmpty) {
// //               // ดึงมาบางส่วน
// //               String firstSeparatedValue = separatedLogs[0][0];
// //               // ดึงมาเฉพาะตัวแรก
// //               String firstSeparatedValueOk = firstSeparatedValue[0][0];
// //               // ตัดตัวแรกของข้อความออก
// //               String firstSeparatedValueYeah = firstSeparatedValue.substring(1);
// //               if (firstSeparatedValueOk == '1') {
// //                 latestValueForLeft = firstSeparatedValueYeah;
// //                 newArray.add(["1", latestValueForLeft]);
// //                 controller.serverLogs.clear();
// //               } else if (firstSeparatedValueOk == '2') {
// //                 latestValueForRight = firstSeparatedValueYeah;
// //                 newArray.add(["2", latestValueForRight]);
// //                 controller.serverLogs.clear();
// //               }
// //             } else {
// //               print("separatedLogs ไม่มีสมาชิก");
// //             }

// //             newArray.sort((a, b) => a[0].compareTo(b[0]));
// //             playQueue(newArray);

// //             return Column(
// //               children: [
// //                 Container(
// //                   color: Colors.black,
// //                   padding: const EdgeInsets.all(16.0),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Expanded(
// //                         child: FutureBuilder<String?>(
// //                           future: getWifiIP(),
// //                           builder: (context, snapshot) {
// //                             if (snapshot.connectionState ==
// //                                 ConnectionState.waiting) {
// //                               // ถ้ากำลังโหลดข้อมูล
// //                               return CircularProgressIndicator();
// //                             } else if (snapshot.hasError ||
// //                                 snapshot.data == null) {
// //                               // ถ้าเกิดข้อผิดพลาดในการโหลดหรือไม่พบข้อมูล
// //                               return Text(
// //                                   'Error: Unable to retrieve WiFi IP Address');
// //                             } else {
// //                               // ถ้าโหลดข้อมูลสำเร็จ
// //                               return Text(
// //                                 'Counter Service Display 1 From : WiFi IP Address: ${snapshot.data}',
// //                                 style: TextStyle(
// //                                   color: Colors.yellow,
// //                                   fontSize:
// //                                       0.025 * MediaQuery.of(context).size.width,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               );
// //                             }
// //                           },
// //                         ),
// //                       ),
// //                       // IconButton(
// //                       //   onPressed: () {
// //                       //     // เพิ่มโค้ดที่ต้องการให้ทำงานเมื่อปุ่มถูกกดที่นี่
// //                       //     Navigator.push(
// //                       //         context,
// //                       //         MaterialPageRoute(
// //                       //             builder: (context) => DisplayScreen2()));
// //                       //   },
// //                       //   icon: Icon(Icons.camera), // เลือกไอคอนตามความเหมาะสม
// //                       //   color: Colors.white, // สีไอคอน
// //                       // ),
// //                     ],
// //                   ),
// //                 ),
// //                 Container(
// //                   color: Colors.white, // พื้นหลังสีขาว
// //                   height: 5.0, // ความสูงของ Divider หนาขึ้น
// //                 ),
// //                 Expanded(
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Flexible(
// //                         flex: 2,
// //                         child: Container(
// //                           color: const Color.fromARGB(255, 6, 55, 95),
// //                           margin: EdgeInsets.all(
// //                               0.02 * MediaQuery.of(context).size.width),
// //                           padding: EdgeInsets.all(
// //                               0.02 * MediaQuery.of(context).size.width),
// //                           child: Align(
// //                             alignment: Alignment.center,
// //                             child: Column(
// //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                               children: [
// //                                 Text(
// //                                   "Counter 1",
// //                                   style: TextStyle(
// //                                     color: Colors.white,
// //                                     fontSize: 0.05 *
// //                                         MediaQuery.of(context)
// //                                             .size
// //                                             .width, // ขนาดตัวอักษรอัตโนมัติ
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   latestValueForLeft1,
// //                                   style: TextStyle(
// //                                     color: isRed ? Colors.red : Colors.yellow,
// //                                     fontSize: textSize,
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                                 Align(
// //                                   alignment: Alignment.bottomLeft,
// //                                   child: Transform.rotate(
// //                                     angle: 5.6,
// //                                     child: Icon(
// //                                       Icons.arrow_back,
// //                                       color: Colors.yellow,
// //                                       size: 0.10 *
// //                                           MediaQuery.of(context)
// //                                               .size
// //                                               .width, // ขนาดไอคอนอัตโนมัติ
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       Flexible(
// //                         flex: 2,
// //                         child: Container(
// //                           color: const Color.fromARGB(255, 6, 55, 95),
// //                           margin: EdgeInsets.all(
// //                               0.02 * MediaQuery.of(context).size.width),
// //                           padding: EdgeInsets.all(
// //                               0.02 * MediaQuery.of(context).size.width),
// //                           child: Align(
// //                             alignment: Alignment.center,
// //                             child: Column(
// //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                               children: [
// //                                 Text(
// //                                   "Counter 2",
// //                                   style: TextStyle(
// //                                     color: Colors.white,
// //                                     fontSize: 0.05 *
// //                                         MediaQuery.of(context)
// //                                             .size
// //                                             .width, // ขนาดตัวอักษรอัตโนมัติ
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   latestValueForRight1,
// //                                   style: TextStyle(
// //                                     color: Colors.yellow,
// //                                     fontSize: textSize,
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                                 Align(
// //                                   alignment: Alignment.bottomRight,
// //                                   child: Transform.rotate(
// //                                     angle: 3.9,
// //                                     child: Icon(
// //                                       Icons.arrow_back,
// //                                       color: Colors.yellow,
// //                                       size: 0.10 *
// //                                           MediaQuery.of(context)
// //                                               .size
// //                                               .width, // ขนาดไอคอนอัตโนมัติ
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   Future<String?>? getWifiIP() async {
// //     try {
// //       final networkInfo = NetworkInfo();
// //       String? wifiIP = await networkInfo.getWifiIP();
// //       return wifiIP;
// //     } catch (e) {
// //       return null;
// //     }
// //   }
// // }

// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get_state_manager/src/simple/get_state.dart';
// import 'controller.dart';

// class DisplayScreen1 extends StatefulWidget {
//   const DisplayScreen1({Key? key}) : super(key: key);

//   @override
//   State<DisplayScreen1> createState() => _DisplayScreen1State();
// }

// class _DisplayScreen1State extends State<DisplayScreen1> {
//   String numberCounterFirst = '';
//   String firstDigit = '';
//   String latestValue = '';
//   String latestValueForLeft = '';
//   String latestValueForLeftt = '';
//   String latestValueForRight = '';
//   String latestValueForLeft1 = '';
//   String latestValueForRight1 = '';
//   String latestValueForLeft3 = '';
//   List<List<String>> newArray = [];
//   List<List<String>> historyArray = [];
//   bool isPlaying = false;
//   int blinkCount = 0; // ตัวแปรสำหรับเก็บจำนวนการกระพริบ
//   bool isRed = false;
//   bool isDisplayedValueRed = false;
//   bool isDisplayedValueRed1 = false;
//   bool isDisplayedValueRed2 = false;

//   void Displaywipwap(String key) async {
//     if (key == '1') {
//       await Future.delayed(Duration(milliseconds: 800));
//       setState(() {
//         isDisplayedValueRed = !isDisplayedValueRed;
//       });

//       for (int i = 0; i < 3; i++) {
//         await Future.delayed(Duration(milliseconds: 800));
//         setState(() {
//           isDisplayedValueRed = !isDisplayedValueRed;
//         });
//         await Future.delayed(Duration(milliseconds: 800));
//         setState(() {
//           isDisplayedValueRed = !isDisplayedValueRed;
//         });
//       }

//       if (blinkCount > 3) {
//         setState(() {
//           isDisplayedValueRed = false;
//         });
//       } else {
//         setState(() {
//           isDisplayedValueRed = false;
//         });
//       }
//     } else if (key == '2') {
//       await Future.delayed(Duration(milliseconds: 800));
//       setState(() {
//         isDisplayedValueRed1 = !isDisplayedValueRed1;
//       });

//       for (int i = 0; i < 3; i++) {
//         await Future.delayed(Duration(milliseconds: 800));
//         setState(() {
//           isDisplayedValueRed1 = !isDisplayedValueRed1;
//         });
//         await Future.delayed(Duration(milliseconds: 800));
//         setState(() {
//           isDisplayedValueRed1 = !isDisplayedValueRed1;
//         });
//       }

//       if (blinkCount > 3) {
//         setState(() {
//           isDisplayedValueRed1 = false;
//         });
//       } else {
//         setState(() {
//           isDisplayedValueRed1 = false;
//         });
//       }
//     } else if (key == "3") {
//       await Future.delayed(Duration(milliseconds: 800));
//       setState(() {
//         isDisplayedValueRed2 = !isDisplayedValueRed2;
//       });

//       for (int i = 0; i < 3; i++) {
//         await Future.delayed(Duration(milliseconds: 800));
//         setState(() {
//           isDisplayedValueRed2 = !isDisplayedValueRed2;
//         });
//         await Future.delayed(Duration(milliseconds: 800));
//         setState(() {
//           isDisplayedValueRed2 = !isDisplayedValueRed2;
//         });
//       }

//       if (blinkCount > 3) {
//         setState(() {
//           isDisplayedValueRed2 = false;
//         });
//       } else {
//         setState(() {
//           isDisplayedValueRed2 = false;
//         });
//       }
//     }
//   }

//   void playQueue(List<List<String>> queue) async {
//     if (!isPlaying && queue.isNotEmpty) {
//       isPlaying = true;
//       List<String> item = queue[0];
//       String key = item[0];
//       String value = item[1];
//       if (key == '1') {
//         latestValueForLeft1 = value;
//         addToHistory("1", latestValueForLeft1);
//         Displaywipwap(key);
//       }

//       if (key == '2') {
//         latestValueForRight1 = value;
//         addToHistory("2", latestValueForRight1);
//         Displaywipwap(key);
//       }

//       // if (key == '3') {
//       // latestValueForLeft3 = value;
//       // addToHistory("3", latestValueForLeft3);
//       // Displaywipwap(key);
//       // }

//       if (key == '1' || key == '2') {
//         await soundVolume(key, value);
//       }
//       queue.removeAt(0);
//       isPlaying = false;
//       playQueue(queue);
//     }
//   }

//   void addToHistory(String key, String value) {
//     historyArray.add([key, value]);
//     if (historyArray.length > 5) {
//       historyArray.removeAt(0); // ลบค่าเก่าสุด
//     }
//     print(historyArray);
//   }

//   Future<void> soundVolume(String key, String queueNumber) async {
//     final player = AudioPlayer();
//     final numberString = queueNumber.toString();
//     // เล่นเสียงตัวแรก
//     await player.play(AssetSource('sounds/number.mp3'));
//     await Future.delayed(Duration(milliseconds: 1500));
//     int consecutiveZeros =
//         0; // เพิ่มตัวแปรเพื่อตรวจสอบเฉพาะการเล่นเสียงเมื่อตัวเลขถัดไปเป็นศูนย์
//     for (int i = 0; i < numberString.length; i++) {
//       String digit = numberString[i];
//       await player.play(AssetSource('sounds/$digit.mp3'));
//       await player.onPlayerStateChanged.firstWhere(
//         (state) => state == PlayerState.completed,
//       ); // รอให้เสียงเล่นเสร็จสิ้นก่อนที่จะดำเนินการต่อ
//       if (digit == '0' &&
//           i < numberString.length - 1 &&
//           numberString[i + 1] == '0') {
//         consecutiveZeros++;
//         if (consecutiveZeros > 1) {
//           // รอเวลาเพิ่มเติมหลังจากเล่นเสียงซ้ำ
//           await Future.delayed(Duration(milliseconds: 800));
//         }
//       } else {
//         consecutiveZeros = 0; // รีเซ็ตตัวแปรเมื่อตัวเลขถัดไปไม่ใช่ศูนย์
//       }
//       // เช็คว่าตัวเลขถัดไปซ้ำกันหรือไม่ ถ้าไม่ซ้ำกันให้เล่นเสียงอีกครั้ง
//       if (i < numberString.length - 1 && digit == numberString[i + 1]) {
//         await Future.delayed(Duration(milliseconds: 100));
//       }
//     }
//     await player.play(AssetSource('sounds/pleasegotocounteranumber.mp3'));
//     await Future.delayed(const Duration(milliseconds: 2500));

//     String numberCounter = key;
//     await player.play(AssetSource('sounds/$numberCounter.mp3'));
//     // รอจนเสร็จสิ้นการเล่นเสียง
//     await player.onPlayerStateChanged
//         .firstWhere((state) => state == PlayerState.completed);
//     // ปิดเสียง
//     await player.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double textSize =
//         0.20 * MediaQuery.of(context).size.width; // กำหนดขนาดตัวอักษรอัตโนมัติ

//     return GestureDetector(
//       onDoubleTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const SetthingScreen()),
//         );
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black, // พื้นหลังสีดำสำหรับ MyWidget
//         body: GetBuilder<ServerController>(
//           init: ServerController(),
//           builder: (controller) {
//             List<String> serverLogStrings =
//                 controller.serverLogs.map((e) => e).toList();
//             Map<String, List<String>> groupedLogs = {};
//             for (String log in serverLogStrings) {
//               String firstCharacter = log.substring(0, 1);
//               firstDigit = firstCharacter;
//               if (!groupedLogs.containsKey(firstCharacter)) {
//                 groupedLogs[firstCharacter] = [];
//               }
//               groupedLogs[firstCharacter]?.add(log);
//             }
//             List<List<String>> separatedLogs = groupedLogs.values.toList();
//             separatedLogs.removeWhere((list) => list.isEmpty);
//             if (separatedLogs.isNotEmpty && separatedLogs[0].isNotEmpty) {
//               // ดึงมาบางส่วน
//               String firstSeparatedValue = separatedLogs[0][0];
//               // ดึงมาเฉพาะตัวแรก
//               String firstSeparatedValueOk = firstSeparatedValue[0][0];
//               // ตัดตัวแรกของข้อความออก
//               String firstSeparatedValueYeah = firstSeparatedValue.substring(1);
//               if (firstSeparatedValueOk == '1') {
//                 latestValueForLeft = firstSeparatedValueYeah;
//                 newArray.add(["1", latestValueForLeft]);
//                 controller.serverLogs.clear();
//               } else if (firstSeparatedValueOk == '2') {
//                 latestValueForRight = firstSeparatedValueYeah;
//                 newArray.add(["2", latestValueForRight]);
//                 controller.serverLogs.clear();
//               } else if (firstSeparatedValueOk == '3') {
//                 latestValueForLeftt = firstSeparatedValueYeah;
//                 newArray.add(["3", latestValueForLeftt]);
//                 controller.serverLogs.clear();
//               }
//             } else {
//               print("separatedLogs ไม่มีสมาชิก");
//             }

//             newArray.sort((a, b) => a[0].compareTo(b[0]));
//             playQueue(newArray);
//             return Column(
//               children: [
//                 Container(
//                   color: Colors.black, // พื้นหลังสีดำ
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     "Counter Service Display 1 ",
//                     style: TextStyle(
//                       color: Colors.yellow,
//                       fontSize: 0.03 *
//                           MediaQuery.of(context)
//                               .size
//                               .width, // ขนาดตัวอักษรอัตโนมัติ
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   color: Colors.white, // พื้นหลังสีขาว
//                   height: 5.0, // ความสูงของ Divider หนาขึ้น
//                 ),
//                 Expanded(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Flexible(
//                         flex: 2,
//                         child: Container(
//                           color: const Color.fromARGB(255, 6, 55, 95),
//                           margin: EdgeInsets.all(
//                               0.02 * MediaQuery.of(context).size.width),
//                           padding: EdgeInsets.all(
//                               0.02 * MediaQuery.of(context).size.width),
//                           child: Align(
//                             alignment: Alignment.center,
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   "Counter 1",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 0.05 *
//                                         MediaQuery.of(context)
//                                             .size
//                                             .width, // ขนาดตัวอักษรอัตโนมัติ
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(
//                                   'A777',
//                                   style: TextStyle(
//                                     color: Colors.yellow,
//                                     // color: isDisplayedValueRed
//                                     //     ? Colors.red
//                                     //     : Colors.yellow,
//                                     fontSize: textSize,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Align(
//                                   alignment: Alignment.bottomLeft,
//                                   child: Transform.rotate(
//                                     angle: 5.6,
//                                     child: Icon(
//                                       Icons.arrow_back,
//                                       color: Colors.yellow,
//                                       size: 0.10 *
//                                           MediaQuery.of(context)
//                                               .size
//                                               .width, // ขนาดไอคอนอัตโนมัติ
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       Flexible(
//                         flex: 2,
//                         child: Container(
//                           color: const Color.fromARGB(255, 6, 55, 95),
//                           margin: EdgeInsets.all(
//                               0.02 * MediaQuery.of(context).size.width),
//                           padding: EdgeInsets.all(
//                               0.02 * MediaQuery.of(context).size.width),
//                           child: Align(
//                             alignment: Alignment.center,
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   "Counter 2",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 0.05 *
//                                         MediaQuery.of(context)
//                                             .size
//                                             .width, // ขนาดตัวอักษรอัตโนมัติ
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(
//                                   latestValueForRight1,
//                                   style: TextStyle(
//                                     // color: Colors.yellow,
//                                     color: isDisplayedValueRed1
//                                         ? Colors.red
//                                         : Colors.yellow,
//                                     fontSize: textSize,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Align(
//                                   alignment: Alignment.bottomRight,
//                                   child: Transform.rotate(
//                                     angle: 3.9,
//                                     child: Icon(
//                                       Icons.arrow_back,
//                                       color: Colors.yellow,
//                                       size: 0.10 *
//                                           MediaQuery.of(context)
//                                               .size
//                                               .width, // ขนาดไอคอนอัตโนมัติ
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
