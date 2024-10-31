import 'package:monitor_2/controller.dart';
import 'package:monitor_2/ip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DisplayScreen1 extends StatefulWidget {
  const DisplayScreen1({Key? key});

  @override
  State<DisplayScreen1> createState() => _DisplayScreen1State();
}

class _DisplayScreen1State extends State<DisplayScreen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ServerController>(
        init: ServerController(),
        builder: (controller) {
          return Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height *
                    0.2, // กำหนดความสูงให้เป็น 10% ของความสูงจอ
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'Counter Service',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Row(
                    children: [
                      // ฝั่งซ้าย
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const IPScreen()),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 28, 15, 120),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Counter 1',
                                  style: TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 170),
                                Center(
                                  child: Text(
                                    'ข้อความด้านซ้าย',
                                    style: TextStyle(
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.yellow,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // ฝั่งขวา
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const IPScreen()),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 28, 15, 120),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Counter 2',
                                  style: TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 170),
                                Center(
                                  child: Text(
                                    'ข้อความด้านขวา',
                                    style: TextStyle(
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.yellow,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
