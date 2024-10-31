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
//   bool isChecked = true;
//   bool isChecked1 = true;
//   bool isChecked2 = true;

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
//                     Column(
//                       children: [
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const SizedBox(width: 20),
//                               ElevatedButton(
//                                 onPressed: () async {
//                                   await controller
//                                       .getIpAddress(); // เรียกฟังก์ชันเพื่อค้นหา IP และกำหนดค่าให้กับ controller.address
//                                   if (controller.address != null) {
//                                     await controller.clientModel!
//                                         .connect(); // เมื่อมี IP ขึ้นมา ให้เรียก .connect() ทันที
//                                   }
//                                   if (controller.address1 != null) {
//                                     await controller.clientModel1!
//                                         .connect(); // เมื่อมี IP ขึ้นมา ให้เรียก .connect() ทันที
//                                   }
//                                   if (controller.address2 != null) {
//                                     await controller.clientModel2!
//                                         .connect(); // เมื่อมี IP ขึ้นมา ให้เรียก .connect() ทันที
//                                   }
//                                 },
//                                 style: ButtonStyle(
//                                   backgroundColor:
//                                       MaterialStateProperty.all<Color>(
//                                           Colors.blue), // กำหนดสีพื้นหลัง
//                                   shape: MaterialStateProperty.all<
//                                       RoundedRectangleBorder>(
//                                     RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(
//                                           18.0), // ปรับความโค้งขอบ
//                                       side: BorderSide(
//                                           color: Colors.white), // กำหนดสีขอบ
//                                     ),
//                                   ),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     const Text(
//                                       "ค้นหา IP",
//                                       style: TextStyle(
//                                           fontSize: 50,
//                                           color:
//                                               Colors.white), // กำหนดสีข้อความ
//                                     ),
//                                     const SizedBox(width: 10),
//                                     SizedBox(
//                                       width: 20,
//                                       height: 20,
//                                       child: controller.address == null
//                                           ? const CircularProgressIndicator(
//                                               valueColor:
//                                                   AlwaysStoppedAnimation<Color>(
//                                                       Colors.white),
//                                               strokeWidth: 10,
//                                             )
//                                           : null,
//                                     )
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         InkWell(
//                           // onTap: controller.address == null
//                           //     ? null
//                           //     : () async {
//                           //         await controller.clientModel!.connect();
//                           //         final info = await deviceInfo.androidInfo;
//                           //         // controller.sendMessage(
//                           //         //     // "connected to ${info.brand} ${info.device}");
//                           //         //     "เชื่อมต่อจาก ${info.brand}")
//                           //         //     ;
//                           //         setState(() {});
//                           //       },
//                           child: Padding(
//                             padding: const EdgeInsets.all(0.5),
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   if (controller.address == null)
//                                     const IgnorePointer(
//                                       ignoring: true,
//                                       child: Text(
//                                         "ไม่มี IP บริเวณนี้ กรุณาโปรด คลิกปุ่ม ค้นหา IP เพื่อตรวจสอบอีกครั้ง",
//                                         style: TextStyle(
//                                             color:
//                                                 Colors.red, // กำหนดสีเป็นสีแดง
//                                             fontSize: 30),
//                                         textAlign: TextAlign
//                                             .center, // จัดให้ข้อความอยู่ตรงกลาง
//                                       ),
//                                     )
//                                   else
//                                     Column(
//                                       children: [
//                                         const Text("รายการ IP",
//                                             style: TextStyle(
//                                                 fontSize: 20,
//                                                 fontWeight: FontWeight.bold)),
//                                         Text(controller.address!.ip,
//                                             style: const TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.bold)),
//                                       ],
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ]),
//                 ),
//               ),
//             ],
//           ));
//     });
//   }
// }
