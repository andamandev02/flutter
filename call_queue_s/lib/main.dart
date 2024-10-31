import 'package:call_queue_s/queue_joy.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('DomainUrl');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(
              235, 241, 248, 120), // กำหนดให้ส่วนหัวของ AppBar เป็นสีโปร่งใส
          elevation: 0, // เพิ่มบรรทัดนี้เพื่อกำหนดให้ไม่มีเงา
        ),
        fontFamily: 'SukhumvitSet',
      ),
      home: const QueueScreen(),
    );
  }
}

// import 'package:call_queue_s/queue_joy.dart';
// import 'package:call_queue_s/queued.dart';
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// void main() async {
//   await Hive.initFlutter();
//   await Hive.openBox('DomainUrl');
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Color.fromARGB(
//               235, 241, 248, 120), // กำหนดให้ส่วนหัวของ AppBar เป็นสีโปร่งใส
//           elevation: 0, // เพิ่มบรรทัดนี้เพื่อกำหนดให้ไม่มีเงา
//         ),
//         fontFamily: 'SukhumvitSet',
//       ),
//       home: const QueueScreenD(),
//     );
//   }
// }
