import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monitor/controller.dart';
import 'package:monitor/display1.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put(ServerController());
    return GetMaterialApp(
      title: 'จอแสดงผล 1',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DisplayScreen1(),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:network_info_plus/network_info_plus.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('IP Address Example'),
//         ),
//         body: Center(
//           child: FutureBuilder<String?>(
//             future: getWifiIP(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return CircularProgressIndicator();
//               } else if (snapshot.hasError || snapshot.data == null) {
//                 return Text('Error: Unable to retrieve WiFi IP Address');
//               } else {
//                 return Text('IP Address: ${snapshot.data}');
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Future<String?>? getWifiIP() async {
//     try {
//       final networkInfo = NetworkInfo();
//       String? wifiIP = await networkInfo.getWifiIP();
//       return wifiIP;
//     } catch (e) {
//       return null;
//     }
//   }
// }
