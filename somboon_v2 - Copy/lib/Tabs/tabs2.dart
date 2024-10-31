import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somboon_v2/provider/provider.dart';
import 'TabData.dart';
import '../api/queue/crud.dart';
import '../api/queue/queuelist.dart';
import '../api/time.dart';
import '../api/url.dart';
import '../cancel_screen.dart';
import '../loadingsreen.dart';
import '../api/brach/brachlist.dart';

class Tab2 extends StatefulWidget {
  const Tab2({
    super.key,
    required this.tabController,
    required this.filteredQueues1Notifier,
    required this.filteredQueues3Notifier,
    required this.filteredQueuesANotifier,
  });

  @override
  _Tab2State createState() => _Tab2State();
  final TabController tabController;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues1Notifier;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues3Notifier;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueuesANotifier;
}

class _Tab2State extends State<Tab2> {
  late List<Map<String, dynamic>> queues = [];
  List<Map<String, dynamic>> filteredQueues1 = [];
  List<Map<String, dynamic>> filteredQueues3 = [];
  List<Map<String, dynamic>> filteredQueuesA = [];

  // List<Map<String, dynamic>> Reason = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQueueNo = '';
  String selectedFilter = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FocusScope.of(context).requestFocus(FocusNode());
    final tabData = TabData.of(context);
    if (tabData != null) {
      fetchSearchQueue(tabData.branches['branch_id'].toString(), _searchQueueNo,
          selectedFilter);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchSearchQueue(
      String branchId, String queueNo, String filter) async {
    await ClassQueue.queuelist(
      context: context,
      branchid: branchId,
      onSearchQueueLoaded: (loadedSearchQueue) {
        if (mounted) {
          setState(() {
            queues = loadedSearchQueue.where((item) {
              //   // กรองคิวตาม queueNo โดยไม่สนใจตัวพิมพ์ใหญ่พิมพ์เล็ก
              //   return item['queue_no']
              //       .toLowerCase()
              //       .contains(queueNo.toLowerCase());
              // }).toList();

              final queueNoMatches = item['queue_no']
                  .toLowerCase()
                  .contains(queueNo.toLowerCase());

              final filterMatches = filter == 'clear' ||
                  item['queue_no'].toLowerCase().contains(filter.toLowerCase());

              return queueNoMatches && filterMatches;
            }).toList();

            filteredQueues1 = queues
                .where((queue) => queue['service_status_id'] == '1')
                .toList();
            filteredQueues3 = queues
                .where((queue) => queue['service_status_id'] == '3')
                .toList();
            filteredQueuesA = queues;

            widget.filteredQueues1Notifier.value = filteredQueues1;
            widget.filteredQueues3Notifier.value = filteredQueues3;
            widget.filteredQueuesANotifier.value = filteredQueuesA;
          });
        }
      },
    );
  }

  void _onSearchChanged(String value) {
    final tabData = TabData.of(context);
    if (tabData != null) {
      setState(() {
        _searchQueueNo = value;
        fetchSearchQueue(tabData.branches['branch_id'].toString(),
            _searchQueueNo, selectedFilter);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hiveData = Provider.of<DataProvider>(context);

    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.06;
    final iconSize = size.height * 0.05;
    final fontSize = size.height * 0.02;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'พิมพ์เพื่อค้นหา Q NO | Search Q No',
                    labelStyle: TextStyle(
                      color: Color(0xFF099FAF),
                      fontSize: fontSize,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(50.0), // กำหนดรัศมีของขอบมน
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(9, 159, 175, 1.0), // สีของเส้นขอบ
                        width: 2.0, // ความหนาของเส้นขอบ
                      ),
                    ),
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _searchController.text.isNotEmpty
                            ? Icons.clear
                            : Icons.search,
                        color: _searchController.text.isNotEmpty
                            ? const Color.fromRGBO(255, 0, 0, 1)
                            : Color(0xFF099FAF),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        selectedFilter == '';
                        setState(() {
                          _searchQueueNo = '';
                          final tabData = TabData.of(context);
                          if (tabData != null) {
                            fetchSearchQueue(
                                tabData.branches['branch_id'].toString(),
                                _searchQueueNo,
                                selectedFilter);
                          }
                        });
                      },
                    ),
                  ),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Color(0xFF099FAF),
                  ),
                  onChanged: _onSearchChanged, // เรียกใช้เมื่อพิมพ์
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: PopupMenuButton<String>(
                    onSelected: (String value) {
                      setState(() {
                        selectedFilter = value;
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'a',
                          child: Text(
                            '     A',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'b',
                          child: Text(
                            '     B',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'c',
                          child: Text(
                            '     C',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'd',
                          child: Text(
                            '     D',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'clear',
                          child: Text(
                            '   clear',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ];
                    },
                    icon: const Icon(
                      Icons.filter_list,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    color: Color(0xFF099FAF),
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: queues.any((item) => item['service_status_id'] == '1')
              ? ListView.builder(
                  itemCount: queues.length,
                  itemBuilder: (context, index) {
                    final item = queues[index];
                    if (item['service_status_id'] == '1') {
                      final tabData = TabData.of(context);
                      final branchId =
                          tabData?.branches['branch_id'].toString() ?? '0';
                      return QueueItemWidget(
                        item: item,
                        buttonHeight: MediaQuery.of(context).size.height * 0.06,
                        size: MediaQuery.of(context).size,
                        branchId: branchId,
                        onQueueUpdated: fetchSearchQueue,
                        tabController: widget.tabController,
                        searchQueueNo: _searchQueueNo,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                )
              : const Center(
                  child: Text(
                    'ไม่มีรายการ',
                    style: TextStyle(
                      fontSize: 20,
                      // fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ), // สามารถปรับแต่ง style ได้ตามต้องการ
                  ),
                ),
        ),
      ],
    );
  }
}

class QueueItemWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final double buttonHeight;
  final Size size;
  final String branchId;
  final TabController tabController;
  // final Future<void> Function(String, String) onQueueUpdated;
  final Future<void> Function(String, String, String) onQueueUpdated;
  final String searchQueueNo;

  const QueueItemWidget({
    super.key,
    required this.item,
    required this.buttonHeight,
    required this.size,
    required this.branchId,
    required this.onQueueUpdated,
    required this.tabController,
    required this.searchQueueNo,
  });

  @override
  _QueueItemWidgetState createState() => _QueueItemWidgetState();
}

class _QueueItemWidgetState extends State<QueueItemWidget> {
  List<Map<String, dynamic>> Reason = [];

  @override
  Widget build(BuildContext context) {
    final hiveData = Provider.of<DataProvider>(context);
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.06;
    final buttonWidth = size.width * 0.2;
    final fontSize = size.height * 0.02;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      child: Container(
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.white, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 1,
                  child: _buildText(
                    "${widget.item['queue_no']}",
                    fontSize * 1.5,
                    Color(0xFF099FAF),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _buildText(
                    (hiveData.givenameValue == 'Checked')
                        ? _formatName("N:${widget.item['customer_name'] ?? ''}")
                        : '',
                    fontSize,
                    Color(0xFF099FAF),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _buildText(
                    (hiveData.givenameValue == 'Checked')
                        ? "T:${widget.item['phone_number'] ?? ''}"
                        : "",
                    fontSize,
                    Color(0xFF099FAF),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 1,
                  child: _buildText(
                    "Number\n${widget.item['number_pax']} PAX",
                    fontSize,
                    const Color.fromARGB(255, 144, 148, 148),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 1,
                  child: _buildText(
                    "Queue\n${formatQueueTime(widget.item['queue_time'])}",
                    fontSize,
                    const Color.fromARGB(255, 144, 148, 148),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 1,
                  child: _buildText(
                    "Wait\n${calculateTimeDifference(widget.item['queue_time'])}",
                    fontSize,
                    const Color.fromARGB(255, 144, 148, 148),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 1,
                  child: _buildElevatedButton(
                    'End',
                    const Color.fromARGB(255, 255, 0, 0),
                    buttonHeight,
                    _endQueue,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 1,
                  child: _buildElevatedButton(
                    'Call',
                    Color(0xFF099FAF),
                    buttonHeight,
                    _callQueue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatName(String fullName) {
    final nameParts = fullName.split(' '); // แยกชื่อและนามสกุล
    if (nameParts.length < 2)
      return fullName; // ถ้ามีแค่ชื่อเดียว ให้ส่งคืนตามปกติ

    final firstName = nameParts[0]; // ชื่อ
    final lastName = nameParts.sublist(1).join(' '); // นามสกุล

    // เช็คความยาวของนามสกุล
    if (lastName.length > 3) {
      return '$firstName ${lastName.substring(0, 3)}...'; // ตัดและเพิ่ม ...
    }
    return fullName; // ส่งคืนชื่อทั้งหมดถ้านามสกุลไม่เกิน 3 ตัว
  }

  // ignore: non_constant_identifier_names
  Widget _buildText(String text, double size, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          // fontWeight: FontWeight.bold,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildElevatedButton(
    String label,
    Color color,
    double height,
    Future<void> Function(BuildContext) onPressed,
  ) {
    return Expanded(
      child: SizedBox(
        height: height,
        width: 150, // กำหนดขนาดคงที่หรือใช้ค่าที่เหมาะสม
        child: ElevatedButton(
          onPressed: () => onPressed(context),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            // side: const BorderSide(color: Colors.black, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  bool _isLoading = false;

  List<Map<String, dynamic>> reasons = [
    {'reason_id': 1, 'reason_note': 'เข้ารับบริการ\nGet in Service'},
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

    Navigator.of(context).pop();

    // นำทางไปหน้า LoadingScreen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          onComplete: () async {
            await Future.delayed(const Duration(seconds: 2));
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  // เมื่อกดปุ่มใน Dialog ให้เรียกใช้ updateQueueAndNavigate โดยส่งค่าที่ถูกต้อง
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
                          onPressed: () async {
                            // Handle queue based on reason_id
                            if (reasons[index]['reason_id'] == 1 ||
                                reasons[index]['reason_id'] == '') {
                              // Simply close the dialog in both cases
                              Navigator.of(context).pop(); // First pop
                              // Navigator.of(context).pop(); // Second pop
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
                                // Navigator.of(context).pop();
                              }
                            } else {
                              // Handle other cases by updating and navigating
                              await updateQueueAndNavigate(
                                context,
                                T2OK,
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

  Future<void> _endQueue(BuildContext context) async {
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => LoadingScreen(
    //       onComplete: () async {
    // await ClassBranch.EndQueueReasonlist(
    //   context: context,
    //   branchid: widget.branchId,
    //   onReasonLoaded: (loadedReason) {
    //     setState(() {
    //       Reason = loadedReason;
    //     });
    //   },
    // );

    // await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => CancelScreen(
    //       // reason: Reason,
    //       T2OK: [widget.item],
    //     ),
    //   ),
    // );

    _showReasonDialog(
      context,
      [widget.item],
    );

    await widget.onQueueUpdated(widget.branchId, widget.searchQueueNo, '');
    //     ),
    //   ),
    // );

    // SnackBarHelper.showSaveSnackBar(
    //   context,
    //   [widget.item],
    //   Reason,
    // );

    // await Future.delayed(const Duration(seconds: 2));
    // await widget.onQueueUpdated(widget.branchId, widget.searchQueueNo, '');
  }

  Future<void> _callQueue(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          onComplete: () async {
            await ClassCQueue().CallQueue(
              context: context,
              SearchQueue: [widget.item],
            );
            await Future.delayed(const Duration(seconds: 1));
            Navigator.of(context).pop();

            // await widget.onQueueUpdated(widget.branchId, widget.searchQueueNo);
            widget.tabController.animateTo(0);
          },
        ),
      ),
    );
  }
}
