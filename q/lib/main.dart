// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;

// void main() {
//   runApp(QuranApp());
// }

// class QuranApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Quran Viewer',
//       theme: ThemeData(primarySwatch: Colors.green),
//       home: QuranHomePage(),
//     );
//   }
// }

// class QuranHomePage extends StatefulWidget {
//   @override
//   _QuranHomePageState createState() => _QuranHomePageState();
// }

// class _QuranHomePageState extends State<QuranHomePage> {
//   late Future<List<Surah>> _surahList;

//   @override
//   void initState() {
//     super.initState();
//     _surahList = loadSurahData();
//   }

//   Future<List<Surah>> loadSurahData() async {
//     final String jsonString = await rootBundle.loadString(
//       'assets/json/surah.json',
//     );
//     final List<dynamic> jsonResponse = json.decode(jsonString);
//     return jsonResponse.map((data) => Surah.fromJson(data)).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Quran Viewer')),
//       body: FutureBuilder<List<Surah>>(
//         future: _surahList,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             final surahs = snapshot.data!;
//             return ListView.builder(
//               itemCount: surahs.length,
//               itemBuilder: (context, index) {
//                 final surah = surahs[index];
//                 return Card(
//                   margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   child: ListTile(
//                     title: Text(
//                       '${surah.index}. ${surah.title} (${surah.titleAr})',
//                     ),
//                     subtitle: Text(
//                       'Place: ${surah.place}, Type: ${surah.type}, Verses: ${surah.count}, Pages: ${surah.pages}',
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => SurahDetailPage(surah: surah),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             );
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error loading data: ${snapshot.error}'));
//           }
//           return Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }
// }

// class SurahDetailPage extends StatelessWidget {
//   final Surah surah;

//   SurahDetailPage({required this.surah});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('${surah.title} (${surah.titleAr})')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Place of Revelation: ${surah.place}',
//               style: TextStyle(fontSize: 16),
//             ),
//             Text('Type: ${surah.type}', style: TextStyle(fontSize: 16)),
//             Text(
//               'Number of Verses: ${surah.count}',
//               style: TextStyle(fontSize: 16),
//             ),
//             Text('Pages: ${surah.pages}', style: TextStyle(fontSize: 16)),
//             SizedBox(height: 20),
//             Text(
//               'Juz Information:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: surah.juz.length,
//                 itemBuilder: (context, index) {
//                   final juz = surah.juz[index];
//                   return ListTile(
//                     title: Text('Juz ${juz.index}'),
//                     subtitle: Text(
//                       'Verses: ${juz.verse.start} to ${juz.verse.end}',
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class Surah {
//   final String place;
//   final String type;
//   final int count;
//   final String title;
//   final String titleAr;
//   final String index;
//   final String pages;
//   final List<Juz> juz;

//   Surah({
//     required this.place,
//     required this.type,
//     required this.count,
//     required this.title,
//     required this.titleAr,
//     required this.index,
//     required this.pages,
//     required this.juz,
//   });

//   factory Surah.fromJson(Map<String, dynamic> json) {
//     var juzList = json['juz'] as List;
//     List<Juz> juzItems = juzList.map((j) => Juz.fromJson(j)).toList();

//     return Surah(
//       place: json['place'],
//       type: json['type'],
//       count: json['count'],
//       title: json['title'],
//       titleAr: json['titleAr'],
//       index: json['index'],
//       pages: json['pages'],
//       juz: juzItems,
//     );
//   }
// }

// class Juz {
//   final String index;
//   final Verse verse;

//   Juz({required this.index, required this.verse});

//   factory Juz.fromJson(Map<String, dynamic> json) {
//     return Juz(index: json['index'], verse: Verse.fromJson(json['verse']));
//   }
// }

// class Verse {
//   final String start;
//   final String end;

//   Verse({required this.start, required this.end});

//   factory Verse.fromJson(Map<String, dynamic> json) {
//     return Verse(start: json['start'], end: json['end']);
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:q/constants.dart';
import 'package:q/fetchadhan.dart';
import 'package:q/intro.dart';
import 'package:q/notes.dart';
import 'package:q/prayertimes.dart';
import 'package:q/qbuddy.dart';
import 'package:q/quran_pdf_viewer.dart';
import 'package:q/randoms.dart';
import 'package:q/testdb.dart';
import 'package:q/tracksalah.dart';
import 'package:quran/surah_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Needed for async in main
  await _initializePrayerTimes();
  log("first point");
  runApp(QuranApp());
}

Future<void> _initializePrayerTimes() async {
  final prefs = await SharedPreferences.getInstance();

  DateTime now = DateTime.now();
  // DateTime now = DateTime.now().add(Duration(days: 0));
  String todayString = "${now.year}-${now.month}-${now.day}";

  String? lastFetchDate = prefs.getString('lastFetchDate');

  bool isFetchDue = lastFetchDate != todayString;
  log("LastFetchDate: $lastFetchDate, isFetchDue: $isFetchDue");
  if (isFetchDue) {
    await fetchPrayerTimes(); // Your implementation

    log("Prayer times fetched and stored for $todayString");
  } else {
    // await lsp(); // Your implementation
    log("Prayer times loaded from storage");
  }
}

class QuranApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran Viewer',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00585A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Text("أهلًا وسهلًا", style: AppTextStyles.smallheading),
                  const SizedBox(height: 10),
                  const Text("أفتاب روشان", style: AppTextStyles.bigheading),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Lottie.asset(
                        'assets/videos/duaj.json',
                        repeat: true, // loops infinitely
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "Make Duas",
                              style: AppTextStyles.midheading,
                              maxLines: 3,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            Text(
                              "between Adhan and \nIqama",
                              style: AppTextStyles.smallheading,
                              maxLines: 3,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                ],
              ),
            ),

            // Grid Section
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 20,
                ),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2,
                  children: [
                    _HomeCard(
                      icon: Icons.menu_book,
                      label: "The Quran",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuranHomePage(),
                          ),
                        );
                      },
                    ),

                    _HomeCard(
                      icon: Icons.verified_user,
                      label: "Promises of Allah",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Testdb()),
                        );
                      },
                    ),
                    _HomeCard(
                      icon: Icons.access_time,
                      label: "Prayer Times",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrayerTimes(),
                          ),
                        );
                      },
                    ),
                    _HomeCard(
                      icon: Icons.wb_sunny,
                      label: "Track",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Tracksalah()),
                        );
                      },
                    ),
                    _HomeCard(
                      icon: Icons.my_library_books_sharp,
                      label: "Notes",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Notes()),
                        );
                      },
                    ),
                    _HomeCard(
                      icon: Icons.explore,
                      label: "Qibla",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Randoms()),
                        );
                      },
                    ),
                    _HomeCard(
                      icon: Icons.favorite,
                      label: "Favorites",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Intro()),
                        );
                      },
                    ),
                    _HomeCard(
                      icon: Icons.chat,
                      label: "Q Buddy",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Qbuddy()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _HomeCard({
    required this.icon,
    required this.label,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red, // You can adjust or remove this
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: const Color(0xFF00585A)),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.smallheading.copyWith(
                  color: AppColors.textdark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuranHomePage extends StatefulWidget {
  @override
  _QuranHomePageState createState() => _QuranHomePageState();
}

class _QuranHomePageState extends State<QuranHomePage> {
  late Future<List<Surah>> _surahList;

  @override
  void initState() {
    super.initState();
    _surahList = loadSurahData();
  }

  Future<List<Surah>> loadSurahData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/json/surah.json',
    );
    final List<dynamic> jsonResponse = json.decode(jsonString);
    return jsonResponse.map((data) => Surah.fromJson(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quran Viewer')),
      body: FutureBuilder<List<Surah>>(
        future: _surahList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final surahs = snapshot.data!;
            return ListView.builder(
              itemCount: surahs.length,
              itemBuilder: (context, index) {
                final surah = surahs[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(
                      '${surah.index}. ${surah.title} (${surah.titleAr})',
                    ),
                    subtitle: Text(
                      'Place: ${surah.place}, Type: ${surah.type}, Verses: ${surah.count}, Pages: ${surah.pages}',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurahDetailPage(surah: surah),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class SurahDetailPage extends StatelessWidget {
  final Surah surah;

  SurahDetailPage({required this.surah});

  @override
  Widget build(BuildContext context) {
    final int firstPage =
        int.tryParse(surah.pages.split('-').first.trim()) ?? 1;

    return Scaffold(
      appBar: AppBar(title: Text('${surah.title} (${surah.titleAr})')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Place of Revelation: ${surah.place}',
              style: TextStyle(fontSize: 16),
            ),
            Text('Type: ${surah.type}', style: TextStyle(fontSize: 16)),
            Text(
              'Number of Verses: ${surah.count}',
              style: TextStyle(fontSize: 16),
            ),
            Text('Pages: ${surah.pages}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.picture_as_pdf),
              label: Text("View in PDF"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) =>
                            QuranApiViewer(surahNumber: int.parse(surah.index)),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              'Juz Information:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: surah.juz.length,
                itemBuilder: (context, index) {
                  final juz = surah.juz[index];
                  return ListTile(
                    title: Text('Juz ${juz.index}'),
                    subtitle: Text(
                      'Verses: ${juz.verse.start} to ${juz.verse.end}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuranPdfViewerPage extends StatefulWidget {
  final int initialPage;

  const QuranPdfViewerPage({required this.initialPage});

  @override
  State<QuranPdfViewerPage> createState() => _QuranPdfViewerPageState();
}

class _QuranPdfViewerPageState extends State<QuranPdfViewerPage> {
  // late PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    // _pdfController = PdfController(
    //   document: PdfDocument.openAsset('assets/pdf/quran.pdf'),
    //   initialPage: widget.initialPage,
    // );
  }

  @override
  void dispose() {
    // _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quran PDF')),

      // body: PdfView(
      //   controller: _pdfController,
      //   scrollDirection: Axis.horizontal,
      // ),
    );
  }
}

// Models

class Surah {
  final String place;
  final String type;
  final int count;
  final String title;
  final String titleAr;
  final String index;
  final String pages;
  final List<Juz> juz;

  Surah({
    required this.place,
    required this.type,
    required this.count,
    required this.title,
    required this.titleAr,
    required this.index,
    required this.pages,
    required this.juz,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    var juzList = json['juz'] as List;
    List<Juz> juzItems = juzList.map((j) => Juz.fromJson(j)).toList();

    return Surah(
      place: json['place'],
      type: json['type'],
      count: json['count'],
      title: json['title'],
      titleAr: json['titleAr'],
      index: json['index'],
      pages: json['pages'],
      juz: juzItems,
    );
  }
}

class Juz {
  final String index;
  final Verse verse;

  Juz({required this.index, required this.verse});

  factory Juz.fromJson(Map<String, dynamic> json) {
    return Juz(index: json['index'], verse: Verse.fromJson(json['verse']));
  }
}

class Verse {
  final String start;
  final String end;

  Verse({required this.start, required this.end});

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(start: json['start'], end: json['end']);
  }
}
