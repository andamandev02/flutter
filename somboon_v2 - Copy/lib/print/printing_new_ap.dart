import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hive/hive.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:somboon_v2/provider/provider.dart';
import 'printerenum.dart';

class PrintNewAP {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException catch (e) {
      print("Error getting bonded devices: $e");
    }

    var printerBox = await Hive.openBox('PrinterDevice');
    String? savedAddress = printerBox.get('PrinterDevice');
    // await printerBox.close();

    if (savedAddress != null) {
      try {
        BluetoothDevice? savedDevice = devices.firstWhere(
          (device) => device.address == savedAddress,
        );

        if (savedDevice != null) {
          _device = savedDevice;

          try {
            await bluetooth.connect(savedDevice);
            _connected = true;
            print("Connected to the Bluetooth device");
          } catch (e) {
            _connected = false;
            print("Failed to connect: $e");
          }
        }
      } catch (e) {
        print("Saved device not found in bonded devices list: $e");
      }
    } else {
      print("กรุณาไปหน้าตั้งค่าเพื่อทำการ เลือกเครื่องพิมพ์ก่อน");
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          _connected = true;
          print("bluetooth device state: connected");
          break;
        case BlueThermalPrinter.DISCONNECTED:
          _connected = false;
          print("bluetooth device state: disconnected");
          break;
        default:
          print(state);
          break;
      }
    });

    _devices = devices;

    if (isConnected == true) {
      _connected = true;
    }
  }

  Future<Uint8List> createQrImage(String data, double size) async {
    await initPlatformState();

    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode;
      final painter = QrPainter.withQr(
        qr: qrCode!,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
      );

      final picData = await painter.toImageData(size);
      return picData!.buffer.asUint8List();
    } else {
      throw Exception('QR code generation failed');
    }
  }

  sample(BuildContext context, Map<String, dynamic> _qrData) async {
    initPlatformState();

    late Uint8List resizedImageBytesAP;
    DateTime queueTime = DateTime.parse(_qrData['data']['queue']['queue_time']);
    String formattedQueueTime =
        "${queueTime.day.toString().padLeft(2, '0')}/${queueTime.month.toString().padLeft(2, '0')}/${queueTime.year} ${queueTime.hour.toString().padLeft(2, '0')}:${queueTime.minute.toString().padLeft(2, '0')}";

    final hiveData = Provider.of<DataProvider>(context, listen: false);

    final queryParameters = {
      'branch_id': _qrData['data']['queue']['branch_id'],
    };

    final uriap =
        Uri.parse('${hiveData.domainValue}/api/v1/queue-mobile/pull-image')
            .replace(queryParameters: queryParameters);
    final responseap = await http.get(
      uriap,
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
    );

    if (responseap.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(responseap.body);

      // ดึงข้อมูลที่ต้องการ
      String baseUrl = jsonData['data']['picture_base_url'];
      String picturePath = jsonData['data']['picture_path'];
      String logoAP = baseUrl + picturePath;

      print('Complete image URL: $logoAP');

      final imageResponse = await http.get(Uri.parse(logoAP));
      if (imageResponse.statusCode == 200) {
        Uint8List imageBytesFromApi = imageResponse.bodyBytes;
        // Resize the image
        img.Image? imageAP = img.decodeImage(imageBytesFromApi);
        if (imageAP != null) {
          img.Image resizedImageAP =
              img.copyResize(imageAP, width: 400, height: 150);
          resizedImageBytesAP =
              Uint8List.fromList(img.encodeJpg(resizedImageAP));
        }

        /// Image from Asset
        ByteData bytesAsset = await rootBundle.load("assets/logo/logo_bk.png");
        Uint8List imageBytesFromAsset = bytesAsset.buffer
            .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

        // Resize the image
        img.Image? image = img.decodeImage(imageBytesFromAsset);
        img.Image resizedImage =
            img.copyResize(image!, width: 450, height: 180);
        Uint8List resizedImageBytes =
            Uint8List.fromList(img.encodeJpg(resizedImage));

        // font1
        ByteData bytesAssetFF = await rootBundle.load("assets/logo/T1.png");
        Uint8List imageBytesFromAssetFF = bytesAssetFF.buffer.asUint8List(
            bytesAssetFF.offsetInBytes, bytesAssetFF.lengthInBytes);

        img.Image? imageFF = img.decodeImage(imageBytesFromAssetFF);
        img.Image resizedImageFF =
            img.copyResize(imageFF!, width: 500, height: 150);
        Uint8List resizedImageBytesFF =
            Uint8List.fromList(img.encodeJpg(resizedImageFF));

        // font2
        ByteData bytesAssetFF1 = await rootBundle.load("assets/logo/T2.png");
        Uint8List imageBytesFromAssetFF1 = bytesAssetFF1.buffer.asUint8List(
            bytesAssetFF1.offsetInBytes, bytesAssetFF1.lengthInBytes);

        img.Image? imageFF1 = img.decodeImage(imageBytesFromAssetFF1);
        img.Image resizedImageFF1 =
            img.copyResize(imageFF1!, width: 500, height: 140);
        Uint8List resizedImageBytesFF1 =
            Uint8List.fromList(img.encodeJpg(resizedImageFF1));

        // font3
        ByteData bytesAssetFF2 = await rootBundle.load("assets/logo/T3.png");
        Uint8List imageBytesFromAssetFF2 = bytesAssetFF2.buffer.asUint8List(
            bytesAssetFF2.offsetInBytes, bytesAssetFF2.lengthInBytes);

        img.Image? imageFF2 = img.decodeImage(imageBytesFromAssetFF2);
        img.Image resizedImageFF2 =
            img.copyResize(imageFF2!, width: 500, height: 150);
        Uint8List resizedImageBytesFF2 =
            Uint8List.fromList(img.encodeJpg(resizedImageFF2));

        // qrcode
        String qrDataUrl =
            '${hiveData.domainValue}/en/app/kiosk/scan-queue?id=';
        final Uint8List qrCodeBytes = await createQrImage(
            '$qrDataUrl${_qrData['data']['queue']['queue_id']}', 150.0);

        // font4
        ByteData bytesAssetFF3 = await rootBundle.load("assets/logo/T4.png");
        Uint8List imageBytesFromAssetFF3 = bytesAssetFF3.buffer.asUint8List(
            bytesAssetFF3.offsetInBytes, bytesAssetFF3.lengthInBytes);

        // Resize the image
        img.Image? imageFF3 = img.decodeImage(imageBytesFromAssetFF3);
        img.Image resizedImageFF3 =
            img.copyResize(imageFF3!, width: 400, height: 200);
        Uint8List resizedImageBytesFF3 =
            Uint8List.fromList(img.encodeJpg(resizedImageFF3));

        // font5
        ByteData bytesAssetFF4 = await rootBundle.load("assets/logo/T5.png");
        Uint8List imageBytesFromAssetFF4 = bytesAssetFF4.buffer.asUint8List(
            bytesAssetFF4.offsetInBytes, bytesAssetFF4.lengthInBytes);

        // Resize the image
        img.Image? imageFF4 = img.decodeImage(imageBytesFromAssetFF4);
        img.Image resizedImageFF4 =
            img.copyResize(imageFF4!, width: 300, height: 50);
        Uint8List resizedImageBytesFF4 =
            Uint8List.fromList(img.encodeJpg(resizedImageFF4));

        //หน้าตาบัตรคิว
        // bluetooth.printImageBytes(resizedImageBytesAP, 1, 1);
        bluetooth.printImageBytes(resizedImageBytes, 70, 70);
        bluetooth.printCustom(
            "${formattedQueueTime}", Size.bold.val, Align.center.val);
        bluetooth.printCustom(
            "${_qrData['data']['queue']['queue_no']}\n${_qrData['data']['queue']['number_pax']} PAX",
            Size.extraLarge.val,
            Align.center.val);
        bluetooth.printImageBytes(resizedImageBytesFF, 1, 1);
        bluetooth.printImageBytes(resizedImageBytesFF1, 1, 1);
        int width = 100;
        int height = 100;
        bluetooth.printImageBytes(qrCodeBytes, width, height);
        bluetooth.printImageBytes(resizedImageBytesFF2, 1, 1);
        bluetooth.printImageBytes(resizedImageBytesFF3, 1, 1);
        bluetooth.printImageBytes(resizedImageBytesFF4, 1, 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    }
  }
}
