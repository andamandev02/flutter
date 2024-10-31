import 'package:flutter/foundation.dart';

class SelectedValuesNotifier extends ChangeNotifier {
  String selectedValue1 = 'A';
  String selectedValue2 = 'B';
  String selectedValue3 = 'C';
  String selectedValue4 = 'D';
  String selectedValueQueue = '4';
  String selectedValueCounter = '2';

  void updateSelectedValue1(String? newValue) {
    selectedValue1 = newValue!;

    notifyListeners();
  }

  void updateSelectedValue2(String? newValue) {
    selectedValue2 = newValue!;
    notifyListeners();
  }

  void updateSelectedValue3(String? newValue) {
    selectedValue3 = newValue!;
    notifyListeners();
  }

  void updateSelectedValue4(String? newValue) {
    selectedValue4 = newValue!;
    notifyListeners();
  }

  void updateSelectedValueQueue(String? newValue) {
    selectedValueQueue = newValue!;
    notifyListeners();
  }

  void updateSelectedValueCounter(String? newValue) {
    selectedValueCounter = newValue!;
    notifyListeners();
  }
}
