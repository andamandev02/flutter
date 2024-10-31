// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:queuecall/controller.dart';

// import '../client.dart';

// class QueueDeviceScreen extends StatefulWidget {
//   const QueueDeviceScreen({super.key});

//   @override
//   State<QueueDeviceScreen> createState() => _QueueDeviceScreenState();
// }

// class _QueueDeviceScreenState extends State<QueueDeviceScreen> {
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//   ClientController clientController = Get.put(ClientController());
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<ClientController>(builder: (controller) {
//       return Scaffold(
//         key: _scaffoldKey,
//         appBar: AppBar(
//           title: Text("Device List"),
//         ),
//         body: Column(
//           children: <Widget>[
//             Expanded(
//                 child: Padding(
//               padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
//               child: Column(children: <Widget>[
//                 if (controller.clientModel == null ||
//                     !controller.clientModel!.isConnected)
//                   Column(
//                     children: [
//                       InkWell(
//                         onTap: () async {
//                           await controller.clientModel!.connect();
//                           final info = await deviceInfo.androidInfo;
//                           setState(() {});
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.all(10.0),
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 if (controller.address == null)
//                                   Text("No Device Found")
//                                 else
//                                   Column(
//                                     children: [
//                                       const Text("Device List"),
//                                       Text(controller.address!.ip),
//                                     ],
//                                   )
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             const SizedBox(
//                               width: 30,
//                               height: 30,
//                               child: CircularProgressIndicator(
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                     Colors.lightBlue),
//                                 strokeWidth: 2,
//                               ),
//                             ),
//                             const SizedBox(
//                               width: 20,
//                             ),
//                             TextButton.icon(
//                               style: ButtonStyle(
//                                   backgroundColor: MaterialStateProperty.all(
//                                       Colors.blue[400])),
//                               onPressed: controller.getIpAddress,
//                               icon: const Icon(
//                                 Icons.search,
//                                 color: Colors.white,
//                               ),
//                               label: const Text("Search"),
//                             )
//                           ],
//                         ),
//                       ),
//                     ],
//                   )
//                 else
//                   Text("Connection To ${controller.clientModel!.hostname}"),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: <Widget>[
//                     const Text("Client"),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(3)),
//                       ),
//                       padding: const EdgeInsets.all(5),
//                       child: Text("Disconnect"),
//                     )
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 15,
//                 ),
//                 if (controller.clientModel == null)
//                   const Text("No Server Found")
//                 else
//                   TextButton(
//                       onPressed: () async {
//                         final AndroidDeviceInfo = await deviceInfo.androidInfo;
//                         if (controller.clientModel!.isConnected) {
//                           debugPrint("Disconnect .....");
//                           controller.clientModel!.disconnect(AndroidDeviceInfo);
//                         } else {
//                           controller.clientModel!.connect();
//                         }
//                         setState(() {});
//                       },
//                       child: Text(!controller.clientModel!.isConnected
//                           ? "Connect"
//                           : "Disconnect")),
//                 const Divider(height: 30, thickness: 1, color: Colors.black12),
//                 Expanded(
//                     child: ListView(
//                   children: [],
//                 ))
//               ]),
//             ))
//           ],
//         ),
//       );
//     });
//   }
// }
