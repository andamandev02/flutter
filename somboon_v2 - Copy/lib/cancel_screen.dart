import 'package:flutter/material.dart';
import 'package:somboon_v2/api/brach/brachlist.dart';
import 'api/queue/crud.dart';
import 'loadingsreen.dart';

class CancelScreen extends StatefulWidget {
  final List<Map<String, dynamic>> T2OK;

  const CancelScreen({
    super.key,
    required this.T2OK,
  });

  @override
  State<CancelScreen> createState() => _CancelScreenState();
}

class _CancelScreenState extends State<CancelScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> Reason = [];

  // Assuming branchId is set correctly in your code.
  get branchId => null; // Update this with the actual branch ID

  @override
  void initState() {
    super.initState();
    fetchReasonNote();
  }

  Future<void> fetchReasonNote() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      await ClassBranch.EndQueueReasonlist(
        context: context,
        branchid: branchId,
        onReasonLoaded: (loadedReason) {
          setState(() {
            Reason = loadedReason;
            _isLoading = false; // Hide loading indicator after data is loaded
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false; // Hide loading indicator if an error occurs
      });
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading reasons: $e'),
        ),
      );
    }
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
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "เลขคิวที่จบบริการ : ${widget.T2OK.isNotEmpty ? widget.T2OK.first['queue_no'] ?? 'N/A' : 'No Data'}",
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(9, 159, 175, 1.0),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator() // Show loading spinner
              else
                ...Reason.map((reason) {
                  final bool isGreen = reason['reason_id'] == '1';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() {
                                _isLoading =
                                    true; // Show loading indicator for button action
                              });

                              var reasonNote = (reason['reason_id'] == '1')
                                  ? 'Finishing'
                                  : 'Ending';

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoadingScreen(
                                    onComplete: () async {
                                      await ClassCQueue().UpdateQueue(
                                        context: context,
                                        SearchQueue: widget.T2OK,
                                        StatusQueue: reasonNote,
                                        StatusQueueNote: reason['reason_id'],
                                      );

                                      Navigator.of(context)
                                          .pop(); // Close LoadingScreen
                                      Navigator.of(context)
                                          .pop(); // Close CancelScreen
                                    },
                                  ),
                                ),
                              );

                              setState(() {
                                _isLoading =
                                    false; // Hide loading indicator after action
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: isGreen
                            ? const Color.fromRGBO(9, 159, 175, 1.0)
                            : const Color.fromARGB(255, 219, 118, 2),
                        minimumSize:
                            Size(screenWidth * 0.8, screenHeight * 0.10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: Text(
                        reason['reason_id'] == '1'
                            ? reason['reason_name'] ?? 'Unknown Reason'
                            : 'ยกเลิก : ${reason['reason_name'] ?? 'Unknown Reason'}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.05,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the screen
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                  minimumSize: Size(screenWidth * 0.8, screenHeight * 0.10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                ),
                child: Text(
                  'ปิดหน้าต่าง',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
