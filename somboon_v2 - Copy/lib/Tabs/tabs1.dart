import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../end_queue.dart';
import '../provider/provider.dart';
import 'TabData.dart';
import '../api/brach/brachlist.dart';
import '../api/queue/crud.dart';
import '../api/queue/queuelist.dart';
import '../api/url.dart';
import '../cancel_screen.dart';
import '../loadingsreen.dart';
import '../numpad/numpad.dart';
import '../setting/setting.dart';

class Tab1 extends StatefulWidget {
  const Tab1({
    super.key,
    required this.filteredQueues1Notifier,
    required this.filteredQueues3Notifier,
    required this.filteredQueuesANotifier,
  });

  @override
  _Tab1State createState() => _Tab1State();
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues1Notifier;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueues3Notifier;
  final ValueNotifier<List<Map<String, dynamic>>> filteredQueuesANotifier;
}

class _Tab1State extends State<Tab1> {
  List<Map<String, dynamic>> filteredQueues1 = [];
  List<Map<String, dynamic>> filteredQueues3 = [];
  List<Map<String, dynamic>> filteredQueuesA = [];

  List<Map<String, dynamic>> queueAll = [];
  late String branchId;

  List<Map<String, dynamic>> queues = [];
  List<Map<String, dynamic>> filteredQueues = [];

  List<Map<String, dynamic>> CallerList = [];

  List<Map<String, dynamic>> Reason = [];

  bool _isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tabData = TabData.of(context);
    if (tabData != null) {
      branchId = tabData.branches['branch_id'];
      fetchCallerQueueAll().then((_) {
        fetchSearchQueue();
      });
    }
  }

  bool _isLoading = false;

  List<Map<String, dynamic>> reasons = [
    {'reason_id': 1, 'reason_note': 'เข้ารับบริการ'},
    {'reason_id': 3, 'reason_note': 'ไม่รอ(คืนคิว)'},
    {'reason_id': 4, 'reason_note': 'ไม่กลับมา'},
    {'reason_id': 5, 'reason_note': 'ออกคิวผิด'},
    {'reason_id': '', 'reason_note': 'ปิดหน้าต่าง'},
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

    await fetchCallerQueueAll();
    await fetchSearchQueue();
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
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(5.0),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                Text(
                  "เลขคิวที่จบบริการ : ${T2OK.isNotEmpty ? T2OK.first['queue_no'] ?? 'N/A' : 'No Data'}",
                  style: const TextStyle(
                    fontSize: 35,
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
                              ? null
                              : () async {
                                  if (reasons[index]['reason_id'] == '') {
                                    Navigator.of(context).pop();
                                  }
                                  await updateQueueAndNavigate(
                                    context,
                                    T2OK, // ส่ง T2OK ไปยังฟังก์ชัน
                                    reasons[index]['reason_id'], // ส่ง reasonId
                                    reasons[index]['reason_note'] ??
                                        '', // ส่ง reasonNote
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: reasons[index]['reason_id'] == 1
                                ? const Color.fromRGBO(9, 159, 175, 1.0)
                                : reasons[index]['reason_id'] == ''
                                    ? const Color.fromARGB(255, 255, 0, 0)
                                    : const Color.fromARGB(255, 219, 118, 2),
                            minimumSize:
                                Size(screenWidth * 0.8, screenHeight * 0.09),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                          ),
                          child: Text(
                            reasons[index]['reason_id'] == 1
                                ? reasons[index]['reason_note'] ?? ''
                                : (reasons[index]['reason_id'] == ''
                                    ? 'ปิดหน้าต่าง'
                                    : 'ยกเลิก : ${reasons[index]['reason_note'] ?? ''}'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
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

  Future<void> fetchCallerQueueAll() async {
    await ClassQueue.CallerQueueAll(
      context: context,
      branchid: branchId,
      onCallerQueueAllLoaded: (loadedCallerQueueAll) {
        if (mounted) {
          setState(() {
            queueAll = loadedCallerQueueAll;
          });
        }
      },
    );
  }

  Future<void> fetchSearchQueue() async {
    await ClassQueue.queuelist(
      context: context,
      branchid: branchId,
      onSearchQueueLoaded: (loadedSearchQueue) {
        if (mounted) {
          setState(() {
            queues = loadedSearchQueue;
            filteredQueues = queues
                .where((queue) => queue['service_status_id'] == '1')
                .toList();
          });

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
        }
      },
    );
  }

  Map<dynamic, int> getCountPerBranchServiceGroup(
      Map<dynamic, List<Map<String, dynamic>>> TQOKK) {
    final countMap = <dynamic, int>{};
    TQOKK.forEach((branchServiceGroupId, queues) {
      countMap[branchServiceGroupId] = queues.length;
    });
    return countMap;
  }

  Widget _buildCard(
    Map<String, dynamic> T1,
    List<Map<String, dynamic>> T2,
    List<Map<String, dynamic>> T2OK,
    String emptyQueueText,
    String nonMatchingQueueText,
    String callingQueueText,
    Map<dynamic, List<Map<String, dynamic>>> TQOKK,
  ) {
    final tabData = TabData.of(context);

    if (tabData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ข้อมูลไม่พร้อมใช้งาน'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // เลือกข้อความที่ต้องแสดงตามสถานะ
    String displayText;
    if (T2.isEmpty) {
      displayText = emptyQueueText;
    } else if (T2OK.isEmpty) {
      displayText = nonMatchingQueueText;
    } else {
      displayText = callingQueueText;
    }

    final TQOKKK = TQOKK.containsKey(T1['branch_service_group_id'])
        ? TQOKK[T1['branch_service_group_id']]!.reduce((a, b) {
            final aId = int.tryParse(a['queue_id'].toString());
            final bId = int.tryParse(b['queue_id'].toString());
            if (aId == null) return b;
            if (bId == null) return a;
            return aId < bId ? a : b;
          })
        : null;

    final countPerGroup = getCountPerBranchServiceGroup(TQOKK);
    final hiveData = Provider.of<DataProvider>(context);

    // รับขนาดหน้าจอ
    final size = MediaQuery.of(context).size;
    final buttonHeight = size.height * 0.06;
    final buttonWidth = size.width * 0.2;
    final fontSize = size.height * 0.02;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.00),
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Text(
                                    'Service\n${T1['service_group_name']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontSize: fontSize,
                                          color: const Color.fromRGBO(
                                              9, 159, 175, 1.0),
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  // Text(
                                  //   '${T1['t_kiosk_btn_name']}',
                                  //   style: Theme.of(context)
                                  //       .textTheme
                                  //       .titleLarge
                                  //       ?.copyWith(
                                  //         fontSize: fontSize,
                                  //         color: const Color.fromARGB(
                                  //             255, 0, 67, 122),
                                  //       ),
                                  //   textAlign: TextAlign.center,
                                  // ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Text(
                                    'wait',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontSize: fontSize,
                                          color: const Color.fromRGBO(
                                              9, 159, 175, 1.0),
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    '${countPerGroup[T1['branch_service_group_id']] ?? 0}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontSize: fontSize,
                                          color: const Color.fromRGBO(
                                              9, 159, 175, 1.0),
                                          fontWeight: FontWeight.bold,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Text(
                                    'next',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontSize: fontSize,
                                          color: const Color.fromRGBO(
                                              9, 159, 175, 1.0),
                                          // fontWeight: FontWeight.bold,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (TQOKKK != null)
                                    Text(
                                      '${TQOKKK['queue_no']}(${TQOKKK['number_pax']})',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontSize: fontSize,
                                            color: const Color.fromRGBO(
                                                9, 159, 175, 1.0),
                                            fontWeight: FontWeight.bold,
                                          ),
                                      textAlign: TextAlign.center,
                                    )
                                  else
                                    Text(
                                      '-',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontSize: fontSize,
                                            color: const Color.fromRGBO(
                                                9, 159, 175, 1.0),
                                            fontWeight: FontWeight.bold,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.all(size.height * 0.01),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color.fromRGBO(
                                            9, 159, 175, 1.0) ??
                                        Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Text(
                                      //   displayText,
                                      //   style: Theme.of(context).textTheme.titleLarge,
                                      // ),
                                      Column(
                                        children: [
                                          if (T2OK.isNotEmpty)
                                            ...T2OK.map(
                                              (queue) => Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .spaceAround, // Spreads the text to opposite ends
                                                children: [
                                                  Text(
                                                    '${queue['queue_no']} ',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge
                                                        ?.copyWith(
                                                          fontSize:
                                                              fontSize * 1.8,
                                                          color: const Color
                                                              .fromRGBO(
                                                              9, 159, 175, 1.0),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  if (hiveData.givenameValue ==
                                                      'Checked')
                                                    Text(
                                                      '${(queue['customer_name'] != null && queue['customer_name'].isNotEmpty) ? 'N : ${queue['customer_name']}' : 'N : -'}\n'
                                                      '${(queue['phone_number'] != null && queue['phone_number'].isNotEmpty) ? 'P : ${queue['phone_number']}' : 'P : -'}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.copyWith(
                                                            fontSize:
                                                                fontSize * 1.0,
                                                            color: const Color
                                                                .fromRGBO(9,
                                                                159, 175, 1.0),
                                                            // fontWeight:
                                                            // FontWeight.bold,
                                                          ),
                                                      textAlign:
                                                          TextAlign.start,
                                                    )
                                                ],
                                              ),
                                            )
                                          else
                                            Text(
                                              '',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    fontSize: fontSize * 1.5,
                                                    color: const Color.fromRGBO(
                                                        9, 159, 175, 1.0),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ปุ่มเพิ่มคิว
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isButtonDisabled
                            ? null
                            : () async {
                                setState(() {
                                  _isButtonDisabled = true;
                                });

                                // var PrinterBox = await Hive.openBox('PrinterDevice');
                                // String? savedAddress =
                                //     PrinterBox.get('PrinterDevice');
                                // await PrinterBox.close();

                                // if (savedAddress == null) {
                                //   String ToMsg = "ยังไม่ได้ทำการ";
                                //   String queueNumber = "เลือกเครื่องพิมพ์";

                                //   SnackBarHelper.showErrorSnackBar(
                                //       context, ToMsg, queueNumber);

                                //   // Future.delayed(const Duration(seconds: 2), () {
                                //   //   Navigator.of(context).pushReplacement(
                                //   //     MaterialPageRoute(
                                //   //         builder: (context) =>
                                //   //             const SettingScreen()),
                                //   //   );
                                //   // });

                                //   return;
                                // }

                                _showNumpad(context, T1);

                                setState(() {
                                  _isButtonDisabled = false;
                                });
                                await Future.delayed(
                                    const Duration(seconds: 2));
                                await fetchCallerQueueAll();
                                await fetchSearchQueue();
                              },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              const Color.fromRGBO(9, 159, 175, 1.0),
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.00),
                          minimumSize: Size(double.infinity, buttonHeight),
                          // side: const BorderSide(
                          //   color: Colors.black,
                          //   width: 2,
                          // ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'ADD Q',
                          style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    if (T2OK.isNotEmpty) ...[
                      // ปุ่มพักคิว
                      // Expanded(
                      //   flex: 1,
                      //   child: ElevatedButton(
                      //     onPressed: _isButtonDisabled
                      //         ? null
                      //         : () async {
                      //             setState(() {
                      //               _isButtonDisabled = true;
                      //             });

                      //             await Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                 builder: (context) => LoadingScreen(
                      //                   onComplete: () async {
                      //                     await ClassCQueue().UpdateQueue(
                      //                       context: context,
                      //                       SearchQueue: T2OK,
                      //                       StatusQueue: 'Holding',
                      //                       StatusQueueNote: '',
                      //                     );

                      //                     await fetchCallerQueueAll();
                      //                     await fetchSearchQueue();

                      //                     Navigator.of(context).pop();
                      //                   },
                      //                 ),
                      //               ),
                      //             );
                      //             setState(() {
                      //               _isButtonDisabled = false;
                      //             });
                      //           },
                      //     style: ElevatedButton.styleFrom(
                      //       foregroundColor: Colors.white,
                      //       backgroundColor:
                      //           const Color.fromRGBO(249, 162, 31, 1),
                      //       padding: EdgeInsets.symmetric(
                      //           vertical: size.height * 0.00),
                      //       minimumSize: Size(double.infinity, buttonHeight),
                      //       // side: const BorderSide(
                      //       //   color: Colors.black,
                      //       //   width: 2,
                      //       // ),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //     ),
                      //     child: Text(
                      //       'Hold',
                      //       style: TextStyle(
                      //         fontSize: fontSize,
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isButtonDisabled
                              ? null
                              : () async {
                                  setState(() {
                                    _isButtonDisabled = true;
                                  });

                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoadingScreen(
                                        onComplete: () async {
                                          await ClassCQueue().UpdateQueue(
                                            context: context,
                                            SearchQueue: T2OK,
                                            StatusQueue: 'Finishing',
                                            StatusQueueNote: '1',
                                          );

                                          await fetchCallerQueueAll();
                                          await fetchSearchQueue();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  );
                                  setState(() {
                                    _isButtonDisabled = false;
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 24, 177, 4),
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.00),
                            minimumSize: Size(double.infinity, buttonHeight),
                            // side: const BorderSide(
                            //   color: Colors.black,
                            //   width: 2,
                            // ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Arrived',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      // ปุ่มจบคิว
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: _isButtonDisabled
                              ? null
                              : () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EndQueueScreen(
                                        T2OK: T2OK,
                                      ),
                                    ),
                                  );

                                  await fetchCallerQueueAll();
                                  await fetchSearchQueue();

                                  // setState(() {
                                  //   _isButtonDisabled = true;
                                  // });

                                  // SnackBarHelper.showSaveSnackBar(
                                  //   context,
                                  //   T2OK,
                                  //   Reason,
                                  // );

                                  // _showReasonDialog(
                                  //   context,
                                  //   T2OK,
                                  // );

                                  // await Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => LoadingScreen(
                                  //       onComplete: () async {
                                  //         await ClassBranch.EndQueueReasonlist(
                                  //           context: context,
                                  //           branchid: branchId,
                                  //           onReasonLoaded: (loadedReason) {
                                  //             setState(() {
                                  //               Reason = loadedReason;
                                  //             });
                                  //           },
                                  //         );

                                  //         await Navigator.push(
                                  //           context,
                                  //           MaterialPageRoute(
                                  //             builder: (context) =>
                                  //                 CancelScreen(
                                  //               reason: Reason,
                                  //               T2OK: T2OK,
                                  //             ),
                                  //           ),
                                  //         );

                                  // await fetchCallerQueueAll();
                                  // await fetchSearchQueue();

                                  // Fetch your data here
                                  // await fetchCallerQueueAll();
                                  // await fetchSearchQueue();
                                  //       },
                                  //     ),
                                  //   ),
                                  // );
                                },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 219, 118, 2),
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.00),
                            minimumSize: Size(double.infinity, buttonHeight),
                            // side: const BorderSide(
                            //   color: Colors.black,
                            //   width: 2,
                            // ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Other',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      // ปุ่มเรียกซ้ำ
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isButtonDisabled
                              ? null
                              : () async {
                                  setState(() {
                                    _isButtonDisabled = true;
                                  });

                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoadingScreen(
                                        onComplete: () async {
                                          await ClassCQueue().UpdateQueue(
                                            context: context,
                                            SearchQueue: T2OK,
                                            StatusQueue: 'Recalling',
                                            StatusQueueNote: '',
                                          );

                                          await fetchCallerQueueAll();
                                          await fetchSearchQueue();

                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  );
                                  setState(() {
                                    _isButtonDisabled = false;
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromRGBO(9, 159, 175, 1.0),
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.00),
                            minimumSize: Size(double.infinity, buttonHeight),
                            // side: const BorderSide(
                            //   color: Colors.black,
                            //   width: 2,
                            // ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Recall',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // ปุ่มพักคิว (ไม่สามารถกดได้)
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 117, 117, 117),
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.00),
                            minimumSize: Size(double.infinity, buttonHeight),
                            // side: const BorderSide(
                            //   color: Colors.black,
                            //   width: 2,
                            // ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Arrived',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      // ปุ่มจบคิว (ไม่สามารถกดได้)
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 117, 117, 117),
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.00),
                            minimumSize: Size(double.infinity, buttonHeight),
                            // side: const BorderSide(
                            //   color: Colors.black,
                            //   width: 2,
                            // ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Other',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      // ปุ่มเรียกคิว
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isButtonDisabled
                              ? null
                              : () async {
                                  setState(() {
                                    _isButtonDisabled = true;
                                  });

                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoadingScreen(
                                        onComplete: () async {
                                          await ClassCQueue().CallerQueue(
                                            context: context,
                                            TicketKioskDetail: T1,
                                            Branch: tabData!.branches,
                                            Kiosk: tabData.counters,
                                            onCallerLoaded:
                                                (loadedSearchQueue) {
                                              setState(() {
                                                CallerList = loadedSearchQueue;
                                              });
                                            },
                                          );

                                          // await Future.delayed(const Duration(seconds: 2));
                                          await fetchCallerQueueAll();
                                          await fetchSearchQueue();

                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  );
                                  setState(() {
                                    _isButtonDisabled = false;
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromRGBO(9, 159, 175, 1.0),
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.00),
                            minimumSize: Size(double.infinity, buttonHeight),
                            // side: const BorderSide(
                            //   color: Colors.black,
                            //   width: 2,
                            // ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Call',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabData = TabData.of(context);

    if (tabData == null) {
      return const Center(child: Text('Data not available'));
    }

    final countersd = tabData.countersd;

    return ListView.builder(
      padding: const EdgeInsets.all(5),
      itemCount: countersd.length,
      itemBuilder: (BuildContext context, int index) {
        final T1 = countersd[index];
        final T2 = queueAll;

        final TQ = filteredQueues;

        final TQOK = TQ
            .where((queue) =>
                queue['branch_service_group_id'] ==
                T1['branch_service_group_id'])
            .toList();

        // จัดกลุ่มและหาข้อมูลเก่าสุด
        final TQOKK = groupBy(TQOK, (item) => item['branch_service_group_id']);

        final T2OK = queueAll
            .where((queue) =>
                queue['branch_service_group_id'] ==
                T1['branch_service_group_id'])
            .toList();

        return _buildCard(
            T1,
            T2,
            T2OK,
            'ไม่มีคิว', // ค่าที่ใช้เมื่อ T2 ว่าง
            'มีคิวแต่ไม่ใช่อันนี้', // ค่าที่ใช้เมื่อ T2 ไม่ว่าง แต่ T2OK ว่าง
            'มีคิวเรียกอยู่',
            TQOKK // ค่าที่ใช้เมื่อ T2OK ไม่ว่าง
            // TQOK, //กรณีที่มีคิวถัดไปของทุกแบบ
            );
      },
    );
  }

  void _showNumpad(BuildContext context, Map<String, dynamic> T1) {
    final tabData = TabData.of(context);

    if (tabData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ข้อมูลไม่พร้อมใช้งาน'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return Scaffold(
          backgroundColor:
              Colors.white, // ตั้งค่าพื้นหลังของ Scaffold เป็นสีขาว
          body: Center(
            child: Container(
              width: double.infinity, // ทำให้กว้างเต็มที่
              height: double.infinity, // ทำให้สูงเต็มที่
              padding: const EdgeInsets.all(5.0),
              color: Colors.white, // ตั้งค่าพื้นหลังของ Container เป็นสีขาว
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Numpad(
                      onSubmit: (pax, name, phone) async {
                        try {
                          SnackBarHelper.showPrinterSnackBar(
                              context,
                              "กำลังพิมพ์บัตรคิว\nPrint",
                              "กรุณารอสักครู่ ...\nPlease Wait...");

                          // เรียกใช้ createQueue
                          await ClassCQueue().createQueue(
                            context: context,
                            Pax: pax,
                            Customername: name,
                            Customerphone: phone,
                            TicketKioskDetail: T1,
                            Branch: tabData.branches,
                            Kiosk: tabData.counters,
                          );

                          await Future.delayed(const Duration(seconds: 3));

                          await fetchCallerQueueAll();
                          await fetchSearchQueue();
                        } catch (e) {
                          String ToMsg = "เกิดข้อผิดพลาดในขั้นตอนสร้างคิว";
                          String queueNumber = '$e';
                          SnackBarHelper.showErrorSnackBar(
                              context, ToMsg, queueNumber);
                        }
                      },
                      T1: T1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
