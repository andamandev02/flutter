import 'package:queuecall/Queue/queue_bottom.dart';
import 'package:queuecall/Queue/queue_device.dart';
import 'package:flutter/material.dart';

class QueueSettingScreen extends StatefulWidget {
  const QueueSettingScreen({Key? key}) : super(key: key);

  @override
  State<QueueSettingScreen> createState() => _QueueSettingScreenState();
}

class _QueueSettingScreenState extends State<QueueSettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: null,
        iconTheme: const IconThemeData(
          color: Colors.grey,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300, // กำหนดความกว้างของปุ่มตามที่ต้องการ
              height: 100, // กำหนดความสูงของปุ่มตามที่ต้องการ
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QueueDeviceScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // เปลี่ยนสีพื้นหลังตามที่ต้องการ
                  onPrimary: Colors.white, // เปลี่ยนสีข้อความ
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    side: BorderSide(
                        color: Colors.white, width: 2.0), // เปลี่ยนสีขอบ
                  ),
                ),
                child: const Text(
                  'ตั้งค่าจอแสดงผล',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16), // ระยะห่างระหว่างปุ่ม
            SizedBox(
              width: 300, // กำหนดความกว้างของปุ่มตามที่ต้องการ
              height: 100, // กำหนดความสูงของปุ่มตามที่ต้องการ
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QueueBottomScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // เปลี่ยนสีพื้นหลังตามที่ต้องการ
                  onPrimary: Colors.white, // เปลี่ยนสีข้อความ
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    side: BorderSide(
                        color: Colors.white, width: 2.0), // เปลี่ยนสีขอบ
                  ),
                ),
                child: const Text(
                  'ตั้งค่าปุ่มกด',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16), // ระยะห่างระหว่างปุ่ม
            SizedBox(
              width: 300, // กำหนดความกว้างของปุ่มตามที่ต้องการ
              height: 100, // กำหนดความสูงของปุ่มตามที่ต้องการ
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange, // เปลี่ยนสีพื้นหลังตามที่ต้องการ
                  onPrimary: Colors.white, // เปลี่ยนสีข้อความ
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    side: BorderSide(
                        color: Colors.white, width: 2.0), // เปลี่ยนสีขอบ
                  ),
                ),
                child: const Text(
                  'กลับไปยังหน้าจอปุ่มกด',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
