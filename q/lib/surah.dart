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
