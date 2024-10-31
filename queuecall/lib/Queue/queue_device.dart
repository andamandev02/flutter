import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:queuecall/Queue/queue_call.dart';
import 'package:queuecall/client.dart';
import 'package:queuecall/controller.dart';

class QueueDeviceScreen extends StatefulWidget {
  const QueueDeviceScreen({Key? key}) : super(key: key);

  @override
  State<QueueDeviceScreen> createState() => _QueueDeviceScreenState();
}

class _QueueDeviceScreenState extends State<QueueDeviceScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final ClientController clientController;
  bool _isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    clientController = Get.put(ClientController());
    clientController.getIpAddresses(); // เรียกเมื่อเปิดหน้าจอ
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      builder: (controller) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              "Device List",
              style: TextStyle(
                fontSize: 30,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // const Text(
                //   "Device List",
                //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                // ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.addresses?.length ?? 0,
                    itemBuilder: (context, index) {
                      final address = controller.addresses?[index];
                      final isConnected =
                          controller.clientModels?[index]?.isConnected ?? false;
                      final backgroundColor =
                          isConnected ? Colors.green : Colors.red;
                      return InkWell(
                        onTap: () async {
                          if (isConnected) {
                            // ถ้าเชื่อมต่ออยู่แล้ว
                            // แสดง dialog ยืนยันการยกเลิกการเชื่อมต่อ
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  "Do you want to disconnect?",
                                  style: TextStyle(fontSize: 18),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final AndroidDeviceInfo =
                                          await deviceInfo.androidInfo;
                                      controller.clientModels?[index]
                                          .disconnect(AndroidDeviceInfo);
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    child: Text("Yes"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // ถ้ายังไม่ได้เชื่อมต่อ
                            await controller.clientModels?[index].connect();
                            setState(() {});
                          }
                        },
                        child: Container(
                          color: backgroundColor,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "IP Address: ${address?.ip ?? 'Unknown'}",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 5),
                              Text(
                                isConnected
                                    ? "สถานะการเชื่อมต่อ : เชื่อมต่อแล้ว"
                                    : "สถานะการเชื่อมต่อ : ยังไม่ได้เชื่อมต่อ",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (controller.addresses?.isEmpty ?? true)
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                      ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isButtonDisabled = true;
                        });

                        // รอเป็นเวลา 2 วินาที
                        Future.delayed(Duration(seconds: 2), () {
                          setState(() {
                            _isButtonDisabled =
                                false; // เปิดให้สามารถกดปุ่มได้อีก
                          });
                        });

                        controller.getIpAddresses();
                      },
                      icon: const Icon(Icons.search),
                      label: const Text("Refresh"),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.blue), // ระบุสีของปุ่มเริ่มต้น
                        overlayColor: MaterialStateProperty.all<Color>(
                            Colors.blue.shade900), // ระบุสีเมื่อปุ่มถูกกด
                        // ระบุสีขอบของปุ่มเมื่อเมาส์ Hover หรือปุ่มถูกกด
                        // สีนี้จะเป็นสีสีขอบของปุ่มเมื่อปุ่มถูกเลือก
                        shadowColor:
                            MaterialStateProperty.all<Color>(Colors.blueAccent),
                      ),
                    ),
                    const SizedBox(width: 20), // เพิ่มระยะห่างระหว่างปุ่ม
                    ElevatedButton.icon(
                      onPressed: () {
                        // เมื่อปุ่มถูกกด ให้นำผู้ใช้ไปยังหน้าอื่น (ในที่นี้เราให้ไปที่หน้า HomeScreen)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  QueueCallScreen()), // HomeScreen คือหน้าปลายทางที่ต้องการไป
                        );
                      },
                      icon: const Icon(
                          Icons.home), // อาจเปลี่ยนไอคอนตามที่ต้องการ
                      label:
                          const Text("HOME"), // อาจเปลี่ยนข้อความตามที่ต้องการ
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
