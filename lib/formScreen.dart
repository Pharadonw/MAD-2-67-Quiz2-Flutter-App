import 'package:account/model/transactionItem.dart';
import 'package:account/provider/transactionProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final formKey = GlobalKey<FormState>();
  final locationController = TextEditingController();
  final sportTypeController = TextEditingController();
  final amountController = TextEditingController();
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  // รายการระดับความรุนแรงของปัญหา
  final List<String> severityLevels = [
    'ต่ำ (Low)',
    'ปานกลาง (Medium)',
    'สูง (High)',
    'วิกฤติ (Critical)'
  ];
  String? selectedSeverity; // ตัวแปรเก็บค่าที่เลือก

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (startTime ?? TimeOfDay.now())
          : (endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Report Errors'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'ข้อความแจ้งเตือนที่เกิดจาก Error'),
                controller: locationController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อน ข้อความแจ้งเตือนที่เกิดจาก Error ";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ประเภทของ Errors '),
                controller: sportTypeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาระบุประเภทของ Errors";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Errors Code'),
                keyboardType: TextInputType.number,
                controller: amountController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อน Errors Code";
                  }
                  try {
                    double amount = double.parse(value);
                    if (amount <= 0) {
                      return "ไม่พบ Error ดังกล่าว กรุณาป้อนใหม่";
                    }
                  } catch (e) {
                    return "กรุณาป้อนเป็นตัวเลข Code เท่านั้น";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Dropdown สำหรับเลือกระดับความรุนแรงของ Error
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'ระดับความรุนแรงของปัญหา'),
                value: selectedSeverity,
                items: severityLevels.map((String severity) {
                  return DropdownMenuItem<String>(
                    value: severity,
                    child: Text(severity),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedSeverity = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'กรุณาเลือกระดับความรุนแรง';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    var provider =
                        Provider.of<TransactionProvider>(context, listen: false);

                    double amount = double.parse(amountController.text);

                    TransactionItem item = TransactionItem(
                      title:
                          '${locationController.text} - ${sportTypeController.text}',
                      amount: amount, 
                      severity: selectedSeverity, // บันทึกค่าความรุนแรง
                      date: DateTime.now(),
                    );

                    provider.addTransaction(item);
                    Navigator.pop(context);
                  }
                },
                child: const Text('บันทึกการ Report Errors'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
