import 'package:flutter/material.dart';

class Numpad extends StatefulWidget {
  final Function(String) onSubmit;
  final Map<String, dynamic> T1;

  Numpad({required this.onSubmit, required this.T1});

  @override
  _NumpadState createState() => _NumpadState();
}

class _NumpadState extends State<Numpad> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.05; // 5% ของความสูงหน้าจอ
    final buttonWidth = size.width * 0.2; // 20% ของความกว้างหน้าจอ

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'จำนวนลูกค้า',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 1),
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: size.width * 0.08,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                _buildNumpad(),
                // const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02),
                          minimumSize: Size(double.infinity, buttonHeight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'ปิด | CANCEL',
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final inputValue = _controller.text;
                          if (inputValue.isEmpty) {
                            _showErrorSnackbar(context, 'กรุณาโปรดป้อนค่า');
                          } else {
                            widget.onSubmit(inputValue);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              const Color.fromRGBO(9, 159, 175, 1.0),
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02),
                          minimumSize: Size(double.infinity, buttonHeight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'ยืนยัน | SUBMIT',
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumpad() {
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

    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: numpadButtons.length,
        itemBuilder: (context, index) {
          final buttonText = numpadButtons[index];
          return SizedBox(
            width: 100,
            height: 100,
            child: ElevatedButton(
              onPressed: () {
                if (buttonText == 'delete') {
                  if (_controller.text.isNotEmpty) {
                    _controller.text = _controller.text
                        .substring(0, _controller.text.length - 1);
                  }
                } else if (buttonText.isNotEmpty) {
                  if (buttonText == '0' && _controller.text.isEmpty) {
                    return;
                  }
                  _controller.text += buttonText;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonText == 'delete'
                    ? const Color.fromARGB(255, 255, 0, 0)
                    : const Color.fromRGBO(9, 159, 175, 1.0),
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
              ),
              child: Center(
                child: Text(
                  buttonText == 'delete' ? 'ลบ' : buttonText,
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    final size = MediaQuery.of(context).size;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          constraints: BoxConstraints(maxWidth: size.width * 0.8),
          height: 60,
          alignment: Alignment.center,
          child: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: size.width * 0.05,
              overflow: TextOverflow.ellipsis,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}