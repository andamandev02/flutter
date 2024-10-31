// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../client.dart';
// import '../controller.dart';

// class QueueDeviceScreen extends StatefulWidget {
//   const QueueDeviceScreen({super.key});

//   @override
//   State<QueueDeviceScreen> createState() => _QueueDeviceScreenState();
// }

// class _QueueDeviceScreenState extends State<QueueDeviceScreen> {
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//   ClientController clientController = Get.put(ClientController());
//   final textController = TextEditingController();
//   bool isChecked = false;
//   bool isChecked1 = false;
//   bool isChecked2 = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<ClientController>(builder: (controller) {
//       return Scaffold(
//           key: _scaffoldKey,
//           appBar: AppBar(
//             title: const Text(
//               'ตั้งค่าจอแสดงผล',
//               style: TextStyle(
//                 fontSize: 24,
//                 color: Colors.black,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             elevation: 0,
//             backgroundColor: Colors.transparent,
//             iconTheme: const IconThemeData(
//               color: Colors.grey,
//             ),
//           ),
//           body: Column(
//             children: <Widget>[
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
//                   child: Column(children: <Widget>[
//                     if (controller.clientModel == null ||
//                         !controller.clientModel!.isConnected)
//                       Column(
//                         children: [
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const SizedBox(
//                                   width: 30,
//                                   height: 30,
//                                   child: CircularProgressIndicator(
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                         Colors.lightBlue),
//                                     strokeWidth: 2,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 20),
//                                 ElevatedButton(
//                                   onPressed: controller.getIpAddress,
//                                   style: ButtonStyle(
//                                     backgroundColor:
//                                         MaterialStateProperty.all<Color>(
//                                             Colors.blue), // กำหนดสีพื้นหลัง
//                                     shape: MaterialStateProperty.all<
//                                         RoundedRectangleBorder>(
//                                       RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(
//                                             18.0), // ปรับความโค้งของขอบ
//                                         side: BorderSide(
//                                             color: Colors.white), // กำหนดสีขอบ
//                                       ),
//                                     ),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       const Text(
//                                         "ค้นหา IP",
//                                         style: TextStyle(
//                                             fontSize: 50,
//                                             color:
//                                                 Colors.white), // กำหนดสีข้อความ
//                                       ),
//                                       const SizedBox(width: 10),
//                                       SizedBox(
//                                         width: 20,
//                                         height: 20,
//                                         child: controller.address == null
//                                             ? const CircularProgressIndicator(
//                                                 valueColor:
//                                                     AlwaysStoppedAnimation<
//                                                         Color>(Colors.white),
//                                                 strokeWidth: 10,
//                                               )
//                                             : null,
//                                       )
//                                     ],
//                                   ),
//                                 )

//                                 // TextButton.icon(
//                                 //   style: ButtonStyle(
//                                 //       backgroundColor:
//                                 //           MaterialStateProperty.all(
//                                 //               Colors.blue[400])),
//                                 //   onPressed: controller.getIpAddress,
//                                 //   icon: Icon(
//                                 //     Icons.search,
//                                 //     color: Colors.white,
//                                 //     size: 24, // ปรับขนาดไอคอน
//                                 //   ),
//                                 //   label: Text(
//                                 //     "Search",
//                                 //     style: TextStyle(
//                                 //       color: Colors.white,
//                                 //       fontSize: 18, // ปรับขนาดฟอนต์ของข้อความ
//                                 //     ),
//                                 //   ),
//                                 // )
//                               ],
//                             ),
//                           ),
//                           SizedBox(
//                             height: 20,
//                           ),
//                           InkWell(
//                             onTap: controller.address == null
//                                 ? null
//                                 : () async {
//                                     await controller.clientModel!.connect();
//                                     final info = await deviceInfo.androidInfo;
//                                     // controller.sendMessage(
//                                     //     // "connected to ${info.brand} ${info.device}");
//                                     //     "เชื่อมต่อจาก ${info.brand}")
//                                     //     ;
//                                     setState(() {});
//                                   },
//                             child: Padding(
//                               padding: const EdgeInsets.all(0.5),
//                               child: Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     if (controller.address == null)
//                                       const IgnorePointer(
//                                         ignoring: true,
//                                         child: Text(
//                                           "ไม่มี IP บริเวณนี้ กรุณาโปรด คลิกปุ่ม ค้นหา IP เพื่อตรวจสอบอีกครั้ง",
//                                           style: TextStyle(
//                                               color: Colors
//                                                   .red, // กำหนดสีเป็นสีแดง
//                                               fontSize: 30),
//                                           textAlign: TextAlign
//                                               .center, // จัดให้ข้อความอยู่ตรงกลาง
//                                         ),
//                                       )
//                                     else
//                                       Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           const Text(
//                                             "รายการ IP ที่เจอ",
//                                             style: TextStyle(
//                                               fontSize: 30,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 15),
//                                           Row(
//                                             children: [
//                                               Transform.scale(
//                                                 scale:
//                                                     1.5, // Adjust the scale factor as needed to increase the size
//                                                 child: Checkbox(
//                                                   value: isChecked,
//                                                   onChanged:
//                                                       (bool? newValue) async {
//                                                     if (newValue != null) {
//                                                       setState(() {
//                                                         isChecked = newValue;
//                                                       });

//                                                       if (controller.address !=
//                                                           null) {
//                                                         await controller
//                                                             .clientModel!
//                                                             .connect();
//                                                         final info =
//                                                             await deviceInfo
//                                                                 .androidInfo;
//                                                         setState(() {});
//                                                       }
//                                                     }
//                                                   },
//                                                 ),
//                                               ),
//                                               Text(
//                                                 "จอแสดงผล Display 1 : ${controller.address!.ip} PORT : ${controller.port}",
//                                                 style: const TextStyle(
//                                                   fontSize: 10,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                                 softWrap:
//                                                     true, // กำหนดให้ข้อความ wrap เมื่อต้องการ
//                                                 overflow: TextOverflow
//                                                     .clip, // กำหนดให้ข้อความไม่เกินขอบเขต
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       )
//                     else
//                       Text("เชื่อมต่อกับ ${controller.clientModel!.hostname}"),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: <Widget>[
//                         const Text(
//                           "Client",
//                           style: TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                         Container(
//                           decoration: const BoxDecoration(
//                             color: Colors.red,
//                             borderRadius: BorderRadius.all(Radius.circular(3)),
//                           ),
//                           padding: const EdgeInsets.all(5),
//                           child: const Text(
//                             "ปิดการเชื่อมต่อ",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 15),
//                     if (controller.clientModel == null)
//                       const Text("")
//                     else
//                       TextButton(
//                         style: ButtonStyle(
//                           backgroundColor:
//                               MaterialStateProperty.resolveWith<Color>(
//                                   (states) {
//                             if (!controller.clientModel!.isConnected) {
//                               return Colors.white12;
//                             } else {
//                               return Colors.red[400]!;
//                             }
//                           }),
//                         ),
//                         onPressed: () async {
//                           final androidDeviceInfo =
//                               await deviceInfo.androidInfo;
//                           if (controller.clientModel!.isConnected) {
//                             debugPrint("Disconnecting....");
//                             controller.clientModel!
//                                 .disconnect(androidDeviceInfo);
//                           } else {
//                             controller.clientModel!.connect();
//                           }
//                           setState(() {});
//                         },
//                         child: Text(
//                           !controller.clientModel!.isConnected
//                               ? ""
//                               : "ยกเลิกการเชื่อมต่อ Counter 1  IP : ${controller.clientModel!.hostname} ",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     const Divider(
//                       height: 10,
//                       thickness: 1,
//                       color: Colors.black12,
//                     ),
//                     const SizedBox(height: 10),
//                     const Text(
//                       "ประวัติการเชื่อมต่อ",
//                       style:
//                           TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 10),
//                     Expanded(
//                         child: ListView(
//                       children: controller.logs.map((e) => Text(e)).toList(),
//                     )),
//                   ]),
//                 ),
//               ),
//               // Container(
//               //   color: Colors.grey[100],
//               //   height: 80,
//               //   padding: const EdgeInsets.all(10),
//               //   child: Row(children: <Widget>[
//               //     Expanded(
//               //       child: Column(
//               //         crossAxisAlignment: CrossAxisAlignment.start,
//               //         children: <Widget>[
//               //           const Text(
//               //             'Send Message :',
//               //             style: TextStyle(
//               //               fontSize: 8,
//               //             ),
//               //           ),
//               //           Expanded(
//               //             child: TextFormField(
//               //               controller: textController,
//               //             ),
//               //           ),
//               //         ],
//               //       ),
//               //     ),
//               //     const SizedBox(
//               //       width: 15,
//               //     ),
//               //     MaterialButton(
//               //       onPressed: () {
//               //         textController.clear();
//               //         setState(() {});
//               //       },
//               //       minWidth: 30,
//               //       padding: const EdgeInsets.symmetric(
//               //           horizontal: 15, vertical: 15),
//               //       child: const Icon(Icons.clear),
//               //     ),
//               //     const SizedBox(
//               //       width: 15,
//               //     ),
//               //     MaterialButton(
//               //       onPressed: () {
//               //         controller.sendMessage(textController.text);
//               //         textController.clear();
//               //         setState(() {});
//               //       },
//               //       minWidth: 30,
//               //       padding: const EdgeInsets.symmetric(
//               //           horizontal: 15, vertical: 15),
//               //       child: const Icon(Icons.send),
//               //     ),
//               //   ]),
//               // )
//             ],
//           ));
//     });
//   }
// }
