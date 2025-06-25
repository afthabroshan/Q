class PrayerStatus {
  final String prayerName;
  final String date; // e.g., '2025-05-01'
  final String status; // 'prayed' or 'missed'

  PrayerStatus({
    required this.prayerName,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {'prayerName': prayerName, 'date': date, 'status': status};
  }

  factory PrayerStatus.fromMap(Map<String, dynamic> map) {
    return PrayerStatus(
      prayerName: map['prayerName'],
      date: map['date'],
      status: map['status'],
    );
  }
}
