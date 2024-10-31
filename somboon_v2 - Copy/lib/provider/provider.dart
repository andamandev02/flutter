import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DataProvider with ChangeNotifier {
  String? _domainValue;
  String? _printerValue;
  String? _givenameValue;

  String? get domainValue => _domainValue;
  String? get givenameValue => _givenameValue;

  // ฟังก์ชันสำหรับโหลดค่าเริ่มต้นจาก Hive box แต่ละตัว
  Future<void> loadData() async {
    await _loadDomainData();
    await _loadGiveNameData();
  }

  // โหลดข้อมูลจาก Hive box ชื่อ 'Domain'
  Future<void> _loadDomainData() async {
    var domainBox = await Hive.openBox('Domain');

    if (domainBox.containsKey('Domain')) {
      _domainValue = domainBox.get('Domain');
    } else {
      _domainValue = '';
      await domainBox.put('Domain', _domainValue);
    }

    notifyListeners();
  }

  // ตั้งค่า ืีทยฟก
  Future<void> _loadGiveNameData() async {
    var GiveNameBox = await Hive.openBox('GiveNameBox');

    if (GiveNameBox.containsKey('GiveNameBox')) {
      _givenameValue = GiveNameBox.get('GiveNameBox');
    } else {
      _givenameValue = '';
      await GiveNameBox.put('GiveNameBox', _givenameValue);
    }

    notifyListeners();
  }

  // ตั้งค่าใหม่ให้กับ Hive box ชื่อ 'Domain'
  Future<void> setDomainValue(String value) async {
    var domainBox = await Hive.openBox('Domain');
    _domainValue = value;
    await domainBox.put('Domain', value);
    notifyListeners();
  }

  // ตั้งค่าใหม่ให้กับ Hive box ชื่อ 'givename'
  Future<void> setGiveNameValue(String value) async {
    var GiveNameBox = await Hive.openBox('GiveNameBox');
    _givenameValue = value;
    await GiveNameBox.put('GiveNameBox', value);
    notifyListeners();
  }
}
