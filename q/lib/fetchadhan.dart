import 'dart:convert';
import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> fetchPrayerTimes() async {
  try {
    Map<String, DateTime> _prayerTimeDates = {};
    Position position = await _getCurrentLocation();
    double latitude = position.latitude;
    double longitude = position.longitude;
    DateTime now = DateTime.now();
    String todayString = "${now.year}-${now.month}-${now.day}";

    final url = Uri.parse(
      'http://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude&method=1',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final timings = data['data']['timings'];

      _prayerTimeDates = {
        'Fajr': _convertToDateTime(timings['Fajr']),
        'Dhuhr': _convertToDateTime(timings['Dhuhr']),
        'Asr': _convertToDateTime(timings['Asr']),
        'Maghrib': _convertToDateTime(timings['Maghrib']),
        'Isha': _convertToDateTime(timings['Isha']),
      };

      // _updateNextPrayer();

      // Optional: Save timings in SharedPreferences if you want offline access
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
        'storedTimings',
        jsonEncode(
          _prayerTimeDates.map(
            (key, value) => MapEntry(key, value.toIso8601String()),
          ),
        ),
      );
      await prefs.setString('lastFetchDate', todayString);
      log("this is the prayer times 45 $_prayerTimeDates");
    } else {
      _prayerTimeDates = {};
    }
  } catch (e) {
    print('Failed to fetch prayer times: $e');
  }
}

// Future<Position> _getCurrentLocation() async {
//   bool serviceEnabled;
//   LocationPermission permission;

//   // Check if location services are enabled
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     await Geolocator.openLocationSettings();
//     return Future.error('Location services are disabled.');
//   }

//   // Check if location permissions are granted
//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       return Future.error('Location permissions are denied');
//     }
//   }

//   // Get current location
//   return await Geolocator.getCurrentPosition(
//     desiredAccuracy: LocationAccuracy.high,
//   );
// }
// Future<Position> _getCurrentLocation() async {
//   bool serviceEnabled;
//   LocationPermission permission;

//   // First check
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();

//   if (!serviceEnabled) {
//     await Geolocator.openLocationSettings();

//     // Wait and check again until location is enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }
//   }

//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       return Future.error('Location permissions are denied');
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     return Future.error(
//       'Location permissions are permanently denied. Please enable them in app settings.',
//     );
//   }

//   return await Geolocator.getCurrentPosition(
//     desiredAccuracy: LocationAccuracy.high,
//   );
// }
Future<Position> _getCurrentLocation({int retries = 5}) async {
  for (int attempt = 0; attempt < retries; attempt++) {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      await Future.delayed(const Duration(seconds: 2));
      continue;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  throw Exception('Failed to get location after multiple attempts');
}

DateTime _convertToDateTime(String prayerTime) {
  // Assuming the time format is "HH:mm" (24-hour format)
  final format = DateFormat("HH:mm");
  final parsedTime = format.parse(
    prayerTime.split(' ')[0],
  ); // Ignore AM/PM part
  final now = DateTime.now();
  return DateTime(
    now.year,
    now.month,
    now.day,
    parsedTime.hour,
    parsedTime.minute,
  );
}
