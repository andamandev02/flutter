import 'package:queuecall/Queue/queue_device.dart';
import 'package:queuecall/Queue/queue_setting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../Provider/provider.dart';
import '../controller.dart';

class QueueCallScreen extends StatefulWidget {
  const QueueCallScreen({super.key});

  @override
  State<QueueCallScreen> createState() => _QueueCallScreenState();
}

class _QueueCallScreenState extends State<QueueCallScreen> {
  late final ClientController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ClientController>();
    controller.getIpAddresses();
  }

  String inputQueue = '';
  String countQueue = '';
  String numberCounter = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ClientController clientController = Get.put(ClientController());
  final textController = TextEditingController();
  List<String> recallArray = [];

  bool isPlaying = false;
  int blinkCount = 0; // ตัวแปรสำหรับเก็บจำนวนการกระพริบ
  bool isRed = false;
  bool isDisplayedValueRed = false;
  bool isDisplayedValueRed1 = false;
  bool isDisplayedValueRed2 = false;

  bool isDisplaying = false; // เพิ่มตัวแปรสถานะ

  void Displaywipwap(String key) async {
    if (key == '1') {
      await Future.delayed(Duration(milliseconds: 800));
      setState(() {
        isDisplayedValueRed = !isDisplayedValueRed;
      });

      for (int i = 0; i < 3; i++) {
        await Future.delayed(Duration(milliseconds: 800));
        setState(() {
          isDisplayedValueRed = !isDisplayedValueRed;
        });
        await Future.delayed(Duration(milliseconds: 800));
        setState(() {
          isDisplayedValueRed = !isDisplayedValueRed;
        });
      }

      if (blinkCount > 3) {
        setState(() {
          isDisplayedValueRed = false;
        });
      } else {
        setState(() {
          isDisplayedValueRed = false;
        });
      }
    } else if (key == '2') {
      await Future.delayed(Duration(milliseconds: 800));
      setState(() {
        isDisplayedValueRed1 = !isDisplayedValueRed1;
      });

      for (int i = 0; i < 3; i++) {
        await Future.delayed(Duration(milliseconds: 800));
        setState(() {
          isDisplayedValueRed1 = !isDisplayedValueRed1;
        });
        await Future.delayed(Duration(milliseconds: 800));
        setState(() {
          isDisplayedValueRed1 = !isDisplayedValueRed1;
        });
      }

      if (blinkCount > 3) {
        setState(() {
          isDisplayedValueRed1 = false;
        });
      } else {
        setState(() {
          isDisplayedValueRed1 = false;
        });
      }
    } else if (key == "3") {
      await Future.delayed(Duration(milliseconds: 800));
      setState(() {
        isDisplayedValueRed2 = !isDisplayedValueRed2;
      });

      for (int i = 0; i < 3; i++) {
        await Future.delayed(Duration(milliseconds: 800));
        setState(() {
          isDisplayedValueRed2 = !isDisplayedValueRed2;
        });
        await Future.delayed(Duration(milliseconds: 800));
        setState(() {
          isDisplayedValueRed2 = !isDisplayedValueRed2;
        });
      }

      if (blinkCount > 3) {
        setState(() {
          isDisplayedValueRed2 = false;
        });
      } else {
        setState(() {
          isDisplayedValueRed2 = false;
        });
      }
    }
  }

  void showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontSize: 24)),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  void onKeyTap(String key, ClientController? controller) {
    if (key == 'Clear') {
      if (!isDisplaying) {
        // ตรวจสอบสถานะการแสดงผล
        setState(() {
          inputQueue = '';
        });
      }
    } else if (key == '+' && controller != null) {
      if (!isDisplaying) {
        if (controller.clientModels == null ||
            controller.clientModels == "" ||
            controller.clientModels.isEmpty) {
          showAlert(context, 'กรุณาเชื่อมต่อ IP ก่อน', '');
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QueueDeviceScreen(),
              ),
            );
          });
        } else if (inputQueue == '' ||
            inputQueue == null ||
            controller.clientModels.isEmpty) {
          showAlert(context, 'ไม่มีคิวรอ', '');
        } else {
          int currentValue = int.parse(inputQueue.substring(1));
          currentValue++;
          inputQueue = inputQueue[0] + currentValue.toString();
          if (!recallArray.isNotEmpty) {
            recallArray.add(inputQueue);
          } else {
            recallArray.removeAt(0);
            recallArray.add(inputQueue);
          }
          Displaywipwap('$numberCounter');
          controller.sendMessage('$numberCounter$inputQueue');
        }
        setState(() {});
      }
      // รองรับเพิ่มเติมตามความต้องการ
    } else if (key == 'Call' && controller != null) {
      if (!isDisplaying) {
        // ตรวจสอบสถานะการแสดงผล
        if (controller.clientModels == null ||
            controller.clientModels == "" ||
            controller.clientModels.isEmpty) {
          showAlert(context, 'กรุณาเชื่อมต่อ IP ก่อน', '');
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QueueDeviceScreen(),
              ),
            );
          });
        } else if (inputQueue == '' || inputQueue == null) {
          showAlert(context, 'กรุณาป้อนเลขคิว', '');
        } else {
          if (!recallArray.isNotEmpty) {
            recallArray.add(inputQueue);
          } else {
            recallArray.removeAt(0);
            recallArray.add(inputQueue);
          }
          Displaywipwap('$numberCounter');
          controller.sendMessage('$numberCounter$inputQueue');
        }
      } else {
        showAlert(context, 'กรุณารอสักครู่ แล้วเรียกคิวใหม่อีกครั้ง', '');
      }
      setState(() {});
    } else if (key == 'Recall') {
      if (!isDisplaying) {
        // ตรวจสอบสถานะการแสดงผล
        if (recallArray.isNotEmpty) {
          setState(() {
            // เรียกซ้ำเฉพาะค่าที่เคยป้อนหน้าจอ
            recallArray.add(inputQueue);
            controller?.sendMessage('$numberCounter$inputQueue');

            // inputQueue = recallArray.removeLast();
            // controller?.sendMessage('$numberCounter$inputQueue');
            // inputQueue = '';
            Displaywipwap('$numberCounter');
          });
        }
      }
    } else if (inputQueue.isEmpty && RegExp(r'[A-Za-z]').hasMatch(key)) {
      // ใส่ตัวเลขหรือตัวอักษรตัวแรก
      setState(() {
        inputQueue = key;
      });
    } else if (inputQueue.isNotEmpty &&
        RegExp(r'[0-9]').hasMatch(key) &&
        inputQueue.length < int.parse(countQueue)) {
      // เมื่อมีตัวเลขหลังตัวอักษรแล้วใส่ตัวเลขเพิ่มเท่านั้น
      setState(() {
        inputQueue += key;
      });
    }
  }

  Widget buildNumpadButton(String label, Color bgColor, Color borderColor,
      Color textColor, double fontSize,
      {bool isTall = false,
      bool isWidth = false,
      required ClientController controller}) {
    double buttonHeight = isTall
        ? 0.2 * MediaQuery.of(context).size.height
        : 0.115 * MediaQuery.of(context).size.height;
    double buttonWidth = isWidth
        ? 0.75 * MediaQuery.of(context).size.width
        : 0.115 * MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () => onKeyTap(label, controller!),
      child: Ink(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: buttonWidth,
          height: buttonHeight,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
                fontSize: 0.025 * MediaQuery.of(context).size.height,
                color: textColor,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(builder: (controller) {
      final selectedValues = Provider.of<SelectedValuesNotifier>(context);
      // String titleText = controller.clientModels != null
      //     ? (controller.clientModels == true
      //         ? "เชื่อมต่อแล้ว"
      //         : "ยังไม่ได้เชื่อมต่อ")
      //     : "กำลังตรวจสอบการเชื่อมต่อ";

      if (controller.clientModels == null) {
        void updateTitleText() {
          Future.delayed(Duration(seconds: 1), () {
            if (controller.clientModels == null) {
              // titleText += ". . .";
              setState(() {});
              updateTitleText();
            }
          });
        }

        updateTitleText();
      }

      countQueue = '${selectedValues.selectedValueQueue}';
      numberCounter = '${selectedValues.selectedValueCounter}';
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          // title: Text(
          //   titleText,
          //   style: TextStyle(
          //       fontSize: 0.02 * MediaQuery.of(context).size.height,
          //       color: Colors.red),
          // ),
          leading: IconTheme(
            data: const IconThemeData(
              color: Colors.grey,
            ),
            child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QueueSettingScreen(),
                  ),
                );
              },
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  minWidth: constraints.maxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 0.25 * MediaQuery.of(context).size.height,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Row(
                            children: [
                              // ฝั่งซ้าย
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 20),
                                    Text(
                                      "Counter",
                                      style: TextStyle(
                                        fontSize: 0.03 *
                                            MediaQuery.of(context).size.height,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      numberCounter,
                                      style: TextStyle(
                                        fontSize: 0.09 *
                                            MediaQuery.of(context).size.height,
                                        color: Colors.yellow,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              // ฝั่งขวา
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 20),
                                    Text(
                                      "Queue",
                                      style: TextStyle(
                                        fontSize: 0.03 *
                                            MediaQuery.of(context).size.height,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      inputQueue,
                                      style: TextStyle(
                                        fontSize: 0.09 *
                                            MediaQuery.of(context).size.height,
                                        // color: Colors.yellow,
                                        color: numberCounter == '1'
                                            ? isDisplayedValueRed
                                                ? Colors.red
                                                : Colors.yellow
                                            : numberCounter == '2'
                                                ? isDisplayedValueRed1
                                                    ? Colors.red
                                                    : Colors.yellow
                                                : numberCounter == '3'
                                                    ? isDisplayedValueRed2
                                                        ? Colors.red
                                                        : Colors.yellow
                                                    : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 0.02 * MediaQuery.of(context).size.height),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildNumpadButton(
                          '${selectedValues.selectedValue1}',
                          const Color.fromARGB(255, 65, 241, 197),
                          Colors.black,
                          Colors.black,
                          0.06 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                        buildNumpadButton(
                          '${selectedValues.selectedValue2}',
                          const Color.fromARGB(255, 65, 241, 197),
                          Colors.black,
                          Colors.black,
                          0.06 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                        buildNumpadButton(
                          '${selectedValues.selectedValue3}',
                          const Color.fromARGB(255, 65, 241, 197),
                          Colors.black,
                          Colors.black,
                          0.06 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                        buildNumpadButton(
                          '${selectedValues.selectedValue4}',
                          const Color.fromARGB(255, 65, 241, 197),
                          Colors.black,
                          Colors.black,
                          0.06 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                      ],
                    ),
                    SizedBox(
                        height: 0.016 * MediaQuery.of(context).size.height),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildNumpadButton(
                          '1',
                          const Color.fromARGB(255, 255, 218, 51),
                          Colors.black,
                          Colors.black,
                          0.04 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                        buildNumpadButton(
                          '2',
                          const Color.fromARGB(255, 255, 218, 51),
                          Colors.black,
                          Colors.black,
                          0.04 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                        buildNumpadButton(
                          '3',
                          const Color.fromARGB(255, 255, 218, 51),
                          Colors.black,
                          Colors.black,
                          0.04 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                        buildNumpadButton(
                          'Clear',
                          Color.fromARGB(255, 86, 196, 232),
                          Colors.black,
                          Colors.black,
                          0.025 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                      ],
                    ),
                    SizedBox(
                        height: 0.016 * MediaQuery.of(context).size.height),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildNumpadButton(
                          '4',
                          const Color.fromARGB(255, 255, 218, 51),
                          Colors.black,
                          Colors.black,
                          0.04 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                        buildNumpadButton(
                          '5',
                          const Color.fromARGB(255, 255, 218, 51),
                          Colors.black,
                          Colors.black,
                          0.04 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                        buildNumpadButton(
                          '6',
                          const Color.fromARGB(255, 255, 218, 51),
                          Colors.black,
                          Colors.black,
                          0.04 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                        buildNumpadButton(
                          '+',
                          Color.fromARGB(255, 0, 68, 255),
                          Colors.black,
                          Colors.white,
                          0.025 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                      ],
                    ),
                    SizedBox(
                        height: 0.016 * MediaQuery.of(context).size.height),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildNumpadButton(
                          '7',
                          const Color.fromARGB(255, 255, 218, 51),
                          Colors.black,
                          Colors.black,
                          0.04 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                        buildNumpadButton(
                          '8',
                          const Color.fromARGB(255, 255, 218, 51),
                          Colors.black,
                          Colors.black,
                          0.04 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                        buildNumpadButton(
                          '9',
                          const Color.fromARGB(255, 255, 218, 51),
                          Colors.black,
                          Colors.black,
                          0.04 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                        buildNumpadButton(
                          'Recall',
                          const Color.fromARGB(255, 65, 241, 197),
                          Colors.black,
                          Colors.black,
                          0.025 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                      ],
                    ),
                    SizedBox(
                        height: 0.016 * MediaQuery.of(context).size.height),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildNumpadButton(
                          '0',
                          const Color.fromARGB(255, 255, 218, 51),
                          Colors.black,
                          Colors.black,
                          0.04 * MediaQuery.of(context).size.height,
                          controller: controller,
                        ),
                        buildNumpadButton(
                          'Call',
                          const Color.fromARGB(255, 255, 218, 51),
                          Colors.black,
                          Colors.black,
                          0.025 * MediaQuery.of(context).size.height,
                          isWidth: true,
                          controller: controller,
                        ),
                        // buildNumpadButton(
                        //   'Call',
                        //   const Color.fromARGB(255, 65, 241, 197),
                        //   Colors.black,
                        //   Colors.black,
                        //   0.025 * MediaQuery.of(context).size.height,
                        //   // isWidth: true,
                        //   controller: controller,
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
