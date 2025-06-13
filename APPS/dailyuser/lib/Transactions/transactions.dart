import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailyuser/backendhelper/getinventoryusername.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  bool loading = true;
  List<Map<String, dynamic>> logs = [];

  @override
  void initState() {
    super.initState();
    loadLogs();
  }

  Future<void> loadLogs() async {
    final inventoryUsername = await getInventoryUsernameForCurrentUser();
    if (inventoryUsername == null) {
      setState(() {
        loading = false;
      });
      return;
    }

    final snap = await FirebaseFirestore.instance
        .collection('logs')
        .where('inventoryusername', isEqualTo: inventoryUsername)
        .orderBy('timestamp', descending: true)
        .get();

    final logsList = snap.docs.map((doc) {
      final data = doc.data();
      return {
        'itemName': data['itemName'] ?? '',
        'type': data['type'] ?? '',
        'quantityChanged': data['quantityChanged'] ?? 0,
        'location': data['location'] ?? '',
        'updatedBy': data['updatedBy'] ?? '',
        'timestamp': data['timestamp'] != null
            ? (data['timestamp'] as Timestamp).toDate()
            : null,
      };
    }).toList();

    setState(() {
      logs = logsList;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Logs"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.yellow,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
          ? const Center(
        child: Text("No logs found", style: TextStyle(color: Colors.white70)),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          columns: const [
            DataColumn(label: Text('Item Name')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('Location')),
            DataColumn(label: Text('Updated By')),
            DataColumn(label: Text('Timestamp')),
          ],
          rows: logs.map((log) {
            return DataRow(cells: [
              DataCell(Text(log['itemName'], style: const TextStyle(color: Colors.white))),
              DataCell(Text(log['type'], style: const TextStyle(color: Colors.white))),
              DataCell(Text(log['quantityChanged'].toString(), style: const TextStyle(color: Colors.white))),
              DataCell(Text(log['location'], style: const TextStyle(color: Colors.white))),
              DataCell(Text(log['updatedBy'], style: const TextStyle(color: Colors.white))),
              DataCell(Text(
                log['timestamp'] != null
                    ? log['timestamp'].toString().split('.')[0]
                    : 'N/A',
                style: const TextStyle(color: Colors.white),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
