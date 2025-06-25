// lib/quran_api_viewer.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran/quran.dart' as quran;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;

class QuranApiViewer extends StatefulWidget {
  final int surahNumber;

  const QuranApiViewer({Key? key, required this.surahNumber}) : super(key: key);

  @override
  _QuranApiViewerState createState() => _QuranApiViewerState();
}

class _QuranApiViewerState extends State<QuranApiViewer> {
  late SharedPreferences _prefs;
  bool _isBookmarked = false;
  List<dynamic> _ayahs = [];
  String _surahName = "";

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    // _fetchSurah(widget.surahNumber);
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      globals.bookmarkedPage =
          _prefs.getInt('bookmarkedPage') ?? globals.DEFAULT_BOOKMARKED_PAGE;
    });
  }

  // Future<void> _fetchSurah(int surahNumber) async {
  //   final url = Uri.parse('http://api.alquran.cloud/v1/surah/$surahNumber');
  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     final decoded = json.decode(response.body);
  //     setState(() {
  //       _surahName = decoded['data']['englishName'];
  //       _ayahs = decoded['data']['ayahs'];
  //     });
  //   } else {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Failed to load Surah')));
  //   }
  // }

  void _bookmarkCurrentSurah() {
    _prefs.setInt('bookmarkedPage', widget.surahNumber);
    setState(() {
      globals.bookmarkedPage = widget.surahNumber;
      _isBookmarked = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Surah ${widget.surahNumber} bookmarked')),
    );
  }

  void _goToBookmarkedSurah() {
    final bookmarked = globals.bookmarkedPage;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuranApiViewer(surahNumber: bookmarked),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Surah $_surahName'),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: _bookmarkCurrentSurah,
          ),
          IconButton(icon: Icon(Icons.book), onPressed: _goToBookmarkedSurah),
        ],
      ),
      body:
          _ayahs.isEmpty
              ? Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: ListView.builder(
                    itemCount: quran.getVerseCount(widget.surahNumber),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          quran.getVerse(
                            widget.surahNumber,
                            index + 1,
                            verseEndSymbol: true,
                          ),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                            height: 2.2,

                            fontFamily: 'Amiri', // Custom Arabic font
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
    );
  }
}
