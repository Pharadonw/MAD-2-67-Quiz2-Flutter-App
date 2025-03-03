import 'package:account/model/transactionItem.dart';
import 'package:account/provider/transactionProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditScreen extends StatefulWidget {
  final TransactionItem item;

  EditScreen({super.key, required this.item});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final formKey = GlobalKey<FormState>();
  final locationController = TextEditingController();
  final sportTypeController = TextEditingController();
  final amountController = TextEditingController();
  String? selectedSeverity;

  // รายการระดับความรุนแรงของปัญหา
  final List<String> severityLevels = [
    'ต่ำ (Low)',
    'ปานกลาง (Medium)',
    'สูง (High)',
    'วิกฤติ (Critical)'
  ];

  @override
  void initState() {
    super.initState();
    
    // โหลดค่าจาก TransactionItem
    var titleParts = widget.item.title.split(' - ');
    locationController.text = titleParts.isNotEmpty ? titleParts[0] : '';
    sportTypeController.text = titleParts.length > 1 ? titleParts[1] : '';
    amountController.text = widget.item.amount.toString();
    selectedSeverity = widget.item.severity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('แก้ไข Error Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'ข้อความแจ้งเตือนที่เกิดจาก Error'),
                controller: locationController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อนข้อความแจ้งเตือนที่เกิดจาก Error";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ประเภทของ Errors'),
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
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 239, 119, 21)),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    var provider = Provider.of<TransactionProvider>(context, listen: false);

                    TransactionItem updatedItem = TransactionItem(
                      keyID: widget.item.keyID,
                      title: '${locationController.text} - ${sportTypeController.text}',
                      amount: double.parse(amountController.text), 
                      severity: selectedSeverity, // บันทึกค่าความรุนแรง
                      date: widget.item.date,
                    );

                    provider.updateTransaction(updatedItem);
                    Navigator.pop(context);
                  }
                },
                child: const Text('บันทึกการแก้ไข', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
