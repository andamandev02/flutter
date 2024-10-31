import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../provider/provider.dart';

class Numpad extends StatefulWidget {
  final Function(String, String, String) onSubmit;
  // final bool isChecked;
  final Map<String, dynamic> T1;

  Numpad({
    super.key,
    required this.onSubmit,
    required this.T1,
    // required this.isChecked,
  });

  @override
  _NumpadState createState() => _NumpadState();
}

class _NumpadState extends State<Numpad> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _customernamecontroller = TextEditingController();
  final TextEditingController _customerphonecontroller =
      TextEditingController();
  PageController _pageController = PageController();

  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  bool isChecked = false;
  late DataProvider _dataProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataProvider = Provider.of<DataProvider>(context);
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    final hiveData = Provider.of<DataProvider>(context);
    String? storedValue = hiveData.givenameValue ?? "Loading...";
    if (storedValue == 'Checked') {
      setState(() {
        isChecked = true;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hiveData = Provider.of<DataProvider>(context);

    final size = MediaQuery.of(context).size;
    final fontSize = size.height * 0.02; // ขนาดฟอนต์ยืดหยุ่น
    final buttonHeight = size.height * 0.05; // ขนาดปุ่มยืดหยุ่น

    return PageView(
      controller: _pageController,
      children: [
        Column(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  // TextField สำหรับจำนวนลูกค้า
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'จำนวนลูกค้า | Pax Qty',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                      style: TextStyle(fontSize: fontSize * 2.4),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Expanded(
                      child: buildNumpad(_controller)), // Numpad ยืดหยุ่นตามจอ
                ],
              ),
            ),

            // ปุ่มด้านล่าง
            Expanded(
              flex: 1, // เพิ่ม Expanded ให้ปุ่มยืดหยุ่น
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(
                            vertical:
                                buttonHeight * 0.6), // ใช้ขนาดปุ่มแบบยืดหยุ่น
                      ),
                      child: Text('ปิด | CANCEL',
                          style: TextStyle(fontSize: fontSize)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final inputValue = _controller.text;
                        if (inputValue.isNotEmpty) {
                          if (isChecked) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            widget.onSubmit(inputValue, '', '');
                            Navigator.pop(context);
                          }
                        } else {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: Colors.orange,
                                      size: fontSize * 1.5,
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Text(
                                        'กรุณาป้อนจำนวนคน',
                                        style:
                                            TextStyle(fontSize: fontSize * 2.2),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.02,
                                  horizontal: size.width * 0.05,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            },
                          );

                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.of(context).pop(); // ปิด Dialog
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromRGBO(9, 159, 175, 1.0),
                        padding: EdgeInsets.symmetric(
                            vertical: buttonHeight * 0.6), // ปรับขนาดปุ่ม
                      ),
                      child: Text(
                        isChecked ? 'ต่อไป | NEXT' : 'ยืนยัน | SUBMIT',
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // หน้า 2: Customer Name และ Phone
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centers the inner Column
                  children: [
                    // ชื่อลูกค้า
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextField(
                        controller: _customernamecontroller,
                        decoration: InputDecoration(
                          hintText: 'ชื่อ | Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        ),
                        style: TextStyle(fontSize: fontSize * 1.3),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // เบอร์โทรศัพท์ลูกค้า
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _customerphonecontroller,
                        decoration: InputDecoration(
                          hintText: 'เบอร์ | Phone',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        ),
                        style: TextStyle(fontSize: fontSize * 1.3),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                              10), // Limit input to 10 characters
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // ปุ่มด้านล่าง
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              vertical: buttonHeight * 0.6),
                        ),
                        child: Text('กลับ | BACK',
                            style: TextStyle(fontSize: fontSize)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final inputValue = _controller.text;
                          final nameinputValue = _customernamecontroller.text;
                          final phoneinputValue = _customerphonecontroller.text;

                          widget.onSubmit(
                              inputValue, nameinputValue, phoneinputValue);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              const Color.fromRGBO(9, 159, 175, 1.0),
                          padding: EdgeInsets.symmetric(
                              vertical: buttonHeight * 0.6),
                        ),
                        child: Text('ยืนยัน | SUBMIT',
                            style: TextStyle(fontSize: fontSize)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildNumpad(TextEditingController controller) {
    final List<String> numpadButtons = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '',
      '0',
      'delete'
    ];
    final size = MediaQuery.of(context).size;
    final fontSize = size.height * 0.03;

    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: (size.width * 0.3).clamp(50.0, 200.0),
          mainAxisSpacing: 4,
          crossAxisSpacing: 58,
          childAspectRatio: 1,
        ),
        itemCount: numpadButtons.length,
        itemBuilder: (context, index) {
          final buttonText = numpadButtons[index];
          return ElevatedButton(
            onPressed: () {
              if (buttonText == 'delete') {
                if (controller.text.isNotEmpty) {
                  controller.text =
                      controller.text.substring(0, controller.text.length - 1);
                }
              } else if (buttonText.isNotEmpty) {
                controller.text += buttonText;
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonText == 'delete'
                  ? Colors.red
                  : const Color.fromRGBO(9, 159, 175, 1.0),
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
            ),
            child: Center(
              child: Text(buttonText == 'delete' ? 'ลบ' : buttonText,
                  style:
                      TextStyle(fontSize: fontSize * 2.0, color: Colors.white)),
            ),
          );
        },
      ),
    );
  }

  Widget buildNumpadphone(TextEditingController controller) {
    final List<String> numpadButtons = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '',
      '0',
      'delete'
    ];
    final size = MediaQuery.of(context).size;
    final fontSize = size.height * 0.025;

    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: (size.width * 0.3).clamp(50.0, 200.0),
          mainAxisSpacing: 1,
          crossAxisSpacing: 75,
          childAspectRatio: 1,
        ),
        itemCount: numpadButtons.length,
        itemBuilder: (context, index) {
          final buttonText = numpadButtons[index];
          return ElevatedButton(
            onPressed: () {
              if (buttonText == 'delete') {
                if (_customerphonecontroller.text.isNotEmpty) {
                  _customerphonecontroller.text = _customerphonecontroller.text
                      .substring(0, _customerphonecontroller.text.length - 1);
                }
              } else if (buttonText.isNotEmpty) {
                // ตรวจสอบความยาวก่อนเพิ่มตัวเลข
                if (_customerphonecontroller.text.length < 13) {
                  _customerphonecontroller.text += buttonText;
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonText == 'delete'
                  ? Colors.red
                  : const Color.fromRGBO(9, 159, 175, 1.0),
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
            ),
            child: Center(
              child: Text(buttonText == 'delete' ? 'ลบ' : buttonText,
                  style:
                      TextStyle(fontSize: fontSize * 2.0, color: Colors.white)),
            ),
          );
        },
      ),
    );
  }
}
