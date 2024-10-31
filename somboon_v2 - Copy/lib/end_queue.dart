import 'package:flutter/material.dart';
import 'package:somboon_v2/api/queue/crud.dart';
import 'package:somboon_v2/loadingsreen.dart';

class EndQueueScreen extends StatefulWidget {
  final List<Map<String, dynamic>> T2OK;

  const EndQueueScreen({
    super.key,
    required this.T2OK,
  });

  @override
  State<EndQueueScreen> createState() => _EndQueueScreenState();
}

class _EndQueueScreenState extends State<EndQueueScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showReasonDialog(
        context,
        widget.T2OK,
      );
    });
  }

  bool _isLoading = false;

  List<Map<String, dynamic>> reasons = [
    {'reason_id': 0, 'reason_note': 'พักคิว\nHold'},
    // {'reason_id': 1, 'reason_note': 'เข้ารับบริการ'},
    {
      'reason_id': 3,
      'reason_note': 'ยกเลิก:ไม่รอ(คืนคิว)\n Cancel : Return Queue'
    },
    {'reason_id': 4, 'reason_note': 'ยกเลิก : ไม่กลับมา\n Cancel : Absent'},
    {
      'reason_id': 5,
      'reason_note': 'ยกเลิก : ออกคิวผิด\n Cancel : Wrong Queue'
    },
    {'reason_id': '', 'reason_note': 'ปิดหน้าต่าง\n Close'},
  ];

  // ปรับปรุงการประกาศฟังก์ชัน updateQueueAndNavigate
  Future<void> updateQueueAndNavigate(BuildContext context,
      List<Map<String, dynamic>> T2OK, int reasonId, String reasonNote) async {
    var ReasonNote = (reasonId == 1) ? 'Finishing' : 'Ending';

    // อัพเดตสถานะของคิว
    await ClassCQueue().UpdateQueue(
      context: context,
      SearchQueue: T2OK,
      StatusQueue: ReasonNote,
      StatusQueueNote: reasonId.toString(),
    );

    if (Navigator.canPop(context)) {
      await Future.delayed(const Duration(seconds: 3));
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  bool _isReasonLoading = false;

  void _showReasonDialog(
      BuildContext context, List<Map<String, dynamic>> T2OK) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        // รับขนาดหน้าจอ
        final size = MediaQuery.of(context).size;
        final buttonHeight = size.height * 0.06;
        final buttonWidth = size.width * 0.2;
        final fontSize = size.height * 0.02;
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(3.0),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                Text(
                  "Queue Number : ${T2OK.isNotEmpty ? T2OK.first['queue_no'] ?? 'N/A' : 'No Data'}",
                  style: TextStyle(
                    fontSize: fontSize * 2.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(9, 159, 175, 1.0),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: ListView.builder(
                    itemCount: reasons.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null // Disable the button if loading
                              : () async {
                                  setState(() {
                                    _isLoading =
                                        true; // Disable all buttons while loading
                                    _isReasonLoading =
                                        true; // Start showing loading state
                                  });

                                  // Handle queue based on reason_id
                                  if (reasons[index]['reason_id'] == 1 ||
                                      reasons[index]['reason_id'] == '') {
                                    // Simply close the dialog in both cases
                                    Navigator.of(context).pop(); // First pop
                                    Navigator.of(context).pop(); // Second pop
                                  } else if (reasons[index]['reason_id'] == 0) {
                                    // Update queue for "Holding" status
                                    await ClassCQueue().UpdateQueue(
                                      context: context,
                                      SearchQueue: T2OK,
                                      StatusQueue: 'Holding',
                                      StatusQueueNote: '',
                                    );

                                    if (Navigator.canPop(context)) {
                                      await Future.delayed(
                                          const Duration(seconds: 3));
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    }
                                  } else {
                                    // Handle other cases by updating and navigating
                                    await updateQueueAndNavigate(
                                      context,
                                      widget.T2OK,
                                      reasons[index]['reason_id'],
                                      reasons[index]['reason_note'] ?? '',
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor:
                                // reasons[index]['reason_id'] == 1
                                // ? const Color.fromRGBO(9, 159, 175, 1.0)
                                reasons[index]['reason_id'] == ''
                                    ? const Color.fromARGB(255, 255, 0, 0)
                                    : reasons[index]['reason_id'] == 0
                                        ? const Color.fromARGB(255, 24, 177, 4)
                                        : const Color.fromARGB(
                                            255, 219, 118, 2),
                            minimumSize:
                                Size(screenWidth * 0.8, screenHeight * 0.09),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                          ),
                          child: Center(
                            child: Text(
                              '${reasons[index]['reason_note']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSize * 1.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
        decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(
        width: 1.0,
        color: const Color.fromARGB(255, 255, 255, 255),
      ),
      borderRadius: BorderRadius.circular(0),
    ));
  }
}
