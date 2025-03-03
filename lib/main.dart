import 'package:account/model/transactionItem.dart';
import 'package:account/provider/transactionProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'formScreen.dart';
import 'editScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Report Software Errors',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 197, 41, 41)),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Report Software Errors'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<TransactionProvider>(context, listen: false).initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.transactions.isEmpty) {
            return const Center(
              child: Text('ไม่พบปัญหา Software Errors',
                  style: TextStyle(fontSize: 20)),
            );
          }
          return ListView.builder(
            itemCount: provider.transactions.length,
            itemBuilder: (context, index) {
              TransactionItem data = provider.transactions[index];
              return Dismissible(
                key: Key(data.keyID.toString()),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) {
                  provider.deleteTransaction(data);
                },
                background: Container(
                  color: Colors.orange,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 12),
                  child: ListTile(
                    title: Text(data.title),
                    subtitle: Text(
                      'ช่วงเวลาส่ง Reports: ${data.date?.hour}:${data.date?.minute} น.\nระดับความรุนแรง: ${data.severity ?? "ไม่ระบุ"}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    leading: const CircleAvatar(child: Icon(Icons.warning)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('ยืนยันการลบ'),
                              content: const Text('คุณต้องการลบรายการนี้ใช่หรือไม่?'),
                              actions: [
                                TextButton(
                                  child: const Text('ยกเลิก'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('ตกลง'),
                                  onPressed: () {
                                    provider.deleteTransaction(data);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditScreen(item: data),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormScreen()),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
