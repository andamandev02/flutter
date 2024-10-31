import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/provider.dart';

class QueueBottomScreen extends StatefulWidget {
  const QueueBottomScreen({Key? key}) : super(key: key);

  @override
  State<QueueBottomScreen> createState() => _QueueBottomScreenState();
}

class _QueueBottomScreenState extends State<QueueBottomScreen> {
  // เก็บจัวอักษรที่ถูกเลือกไว้ในแต่ละปุ่ม
  Map<String, Set<String>> selectedLettersMap = {
    'Button1': Set(),
    'Button2': Set(),
    'Button3': Set(),
    'Button4': Set(),
  };

  @override
  Widget build(BuildContext context) {
    final selectedValues = Provider.of<SelectedValuesNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Setting',
          style: TextStyle(
            fontSize: 30,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Colors.grey,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              buildRowDropdown('ปุ่มที่ 1', selectedValues.selectedValue1,
                  selectedValues.updateSelectedValue1, 'Button1'),
              const SizedBox(height: 20),
              buildRowDropdown('ปุ่มที่ 2', selectedValues.selectedValue2,
                  selectedValues.updateSelectedValue2, 'Button2'),
              const SizedBox(height: 20),
              buildRowDropdown('ปุ่มที่ 3', selectedValues.selectedValue3,
                  selectedValues.updateSelectedValue3, 'Button3'),
              const SizedBox(height: 20),
              buildRowDropdown('ปุ่มที่ 4', selectedValues.selectedValue4,
                  selectedValues.updateSelectedValue4, 'Button4'),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 2,
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              buildRowDropdownQueue(
                  'จำนวนหลักคิว',
                  selectedValues.selectedValueQueue,
                  selectedValues.updateSelectedValueQueue),
              const SizedBox(height: 20),
              buildRowDropdownCounter(
                  '      ช่องบริการ',
                  selectedValues.selectedValueCounter,
                  selectedValues.updateSelectedValueCounter),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRowDropdown(String labelText, String selectedValue,
      void Function(String?) onChanged, String buttonName) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(labelText, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 20),
            Expanded(
              child: buildDropdown(selectedValue, onChanged, buttonName),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildDropdown(String selectedValue, void Function(String?) onChanged,
      String buttonName) {
    List<String> availableLetters = List.generate(26, (index) {
      String letter = String.fromCharCode(65 + index);
      return letter;
    }).where((letter) {
      // ตรวจสอบว่าตัวอักษรนี้ถูกเลือกในปุ่มอื่น ๆ หรือไม่
      for (var key in selectedLettersMap.keys) {
        if (key != buttonName && selectedLettersMap[key]!.contains(letter)) {
          return false;
        }
      }
      return true;
    }).toList();

    if (!availableLetters.contains(selectedValue)) {
      selectedValue = availableLetters.isNotEmpty ? availableLetters[0] : '';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          onChanged: (newValue) {
            selectedLettersMap[buttonName]!.remove(selectedValue);
            selectedLettersMap[buttonName]!.add(newValue!);
            onChanged(newValue);
            setState(() {});
          },
          items: availableLetters.map((letter) {
            return DropdownMenuItem<String>(
              value: letter,
              child: Text(letter),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildRowDropdownQueue(String labelText, String selectedValue,
      void Function(String?) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(labelText, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 20),
            Expanded(
              child: buildDropdownQueue(selectedValue, onChanged),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildRowDropdownCounter(String labelText, String selectedValue,
      void Function(String?) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(labelText, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 20),
            Expanded(
              child: buildDropdownCounter(selectedValue, onChanged),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildDropdownCounter(
      String selectedValue, void Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          onChanged: onChanged,
          items: List.generate(3, (index) {
            int number = index + 1;
            return DropdownMenuItem<String>(
              value: number.toString(),
              child: Text(number.toString()),
            );
          }),
        ),
      ),
    );
  }

  Widget buildDropdownQueue(
      String selectedValue, void Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          onChanged: onChanged,
          items: List.generate(5, (index) {
            int number = index + 1;
            return DropdownMenuItem<String>(
              value: number.toString(),
              child: Text(number.toString()),
            );
          }),
        ),
      ),
    );
  }
}
