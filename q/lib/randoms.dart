import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:q/constants.dart';
import 'package:q/groqservices.dart';
// This should contain runVerse()

class Randoms extends StatefulWidget {
  const Randoms({super.key});

  @override
  State<Randoms> createState() => _RandomsState();
}

class _RandomsState extends State<Randoms> {
  List<Map<String, String>>? verse;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRandomVerse();
  }

  Future<void> fetchRandomVerse() async {
    setState(() => isLoading = true);
    final fetchedVerse =
        await GroqAIService.runVerse(); // or just runVerse() if it's not in a class
    setState(() {
      verse = fetchedVerse;
      log("from 100 $verse");
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Random Verse',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchRandomVerse,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : verse == null
                  ? const Center(child: Text("Failed to load verse"))
                  : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...verse!
                            .map(
                              (v) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Card(
                                  elevation: 4,
                                  color: AppColors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          v['arabic'] ?? '',
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.midheading,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          v['translation'] ?? '',
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.smallheading,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
