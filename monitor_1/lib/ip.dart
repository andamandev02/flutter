import 'package:monitor_1/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IPScreen extends StatefulWidget {
  const IPScreen({Key? key}) : super(key: key);

  @override
  State<IPScreen> createState() => _IPScreenState();
}

class _IPScreenState extends State<IPScreen> {
  final ServerController controller = Get.find<ServerController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      controller.startOrStopServer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Server"),
      ),
      body: GetBuilder<ServerController>(
        init: controller,
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Server",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: controller.server!.running
                                  ? Colors.green[400]
                                  : Colors.red[400],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              controller.server!.running
                                  ? "กำลังเปิดใช้งาน"
                                  : "ปิดการใช้งานอยู่",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () async {
                          controller.startOrStopServer();
                        },
                        child: Text(
                          controller.server!.running
                              ? "หยุดการเปิด IP ${controller.server!.wifiIPv4S}"
                              : "เริ่มต้นเปิดใช้งาน IP",
                        ),
                      ),
                      const Divider(
                        height: 30,
                        thickness: 1,
                      ),
                      Expanded(
                        child: ListView(
                          children: controller.serverLogs
                              .map((e) => Text("$e"))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 80,
                color: Colors.grey[200],
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.messageController,
                        decoration:
                            const InputDecoration(labelText: "ส่งข้อความ"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        controller.messageController.clear();
                      },
                      icon: const Icon(Icons.clear),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: controller.handelMessage,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
