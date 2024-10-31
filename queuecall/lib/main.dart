import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:queuecall/Queue/queue_call.dart';
import 'package:provider/provider.dart';
import 'package:queuecall/controller.dart';
import 'Provider/provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    Get.put(ClientController());
    return ChangeNotifierProvider(
      create: (context) => SelectedValuesNotifier(),
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const QueueCallScreen(),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
