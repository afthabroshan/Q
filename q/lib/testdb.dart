import 'package:flutter/material.dart';
import 'package:q/prayerSDBhelper.dart';

class Testdb extends StatefulWidget {
  const Testdb({super.key});

  @override
  State<Testdb> createState() => _TestdbState();
}

class _TestdbState extends State<Testdb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Center(child: Text("Be Aware")),
            Center(
              child: FloatingActionButton(
                onPressed: () async {
                  await PrayerDBHelper().clearAllStatuses();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All prayer statuses cleared.')),
                  );
                  setState(() {}); // Refresh UI if needed
                },
                child: Icon(Icons.delete),
                tooltip: 'Clear All Prayers',
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
