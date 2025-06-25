import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:lottie/lottie.dart';
import 'package:q/constants.dart';
import 'package:q/prayerSDBhelper.dart';
import 'package:q/prayerstatus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimes extends StatefulWidget {
  const PrayerTimes({super.key});

  @override
  _PrayerTimesState createState() => _PrayerTimesState();
}

class _PrayerTimesState extends State<PrayerTimes> {
  Map<String, DateTime> _prayerTimeDates = {};
  Map<String, bool> _showCheckbox = {};
  Map<String, bool> _prayerDone = {};

  String _nextPrayer = '';
  String _countdownMessage = '';
  String _prayerCountdown = '';
  Timer? _countdownTimer;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    lsp();
    // _fetchPrayerTimes();
    // loadStoredPrayerTimes();
    _startLiveCountdown();
    _prayerTimeDates.keys.forEach((prayer) {
      _showCheckbox[prayer] = false;
      _prayerDone[prayer] = false;
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> lsp() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('storedTimings');
    if (stored != null) {
      final Map<String, dynamic> decoded = jsonDecode(stored);
      _prayerTimeDates = decoded.map(
        (key, value) => MapEntry(key, DateTime.parse(value)),
      );
      _updateNextPrayer();
      _isLoading = false;
      // setState(() {
      //   _isLoading = false;
      // });
      log("this is from 59 $_prayerTimeDates");
    }
  }

  Future<void> _fetchPrayerTimes() async {
    // Get current location
    Position position = await _getCurrentLocation();
    double latitude = position.latitude;
    double longitude = position.longitude;

    // API URL for Aladhan
    final url = Uri.parse(
      'http://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude&method=1',
    );

    // Make API call
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // Parse the response
      final data = jsonDecode(response.body);
      final timings = data['data']['timings'];

      setState(() {
        _prayerTimeDates = {
          'Fajr': _convertToDateTime(timings['Fajr']),
          'Dhuhr': _convertToDateTime(timings['Dhuhr']),
          'Asr': _convertToDateTime(timings['Asr']),
          'Maghrib': _convertToDateTime(timings['Maghrib']),
          'Isha': _convertToDateTime(timings['Isha']),
        };
        _isLoading = false;
        _updateNextPrayer();
      });
    } else {
      setState(() {
        _prayerTimeDates = {}; // Clear existing times if API fails
      });
    }
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

  void _startLiveCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateNextPrayer(); // Update the prayer time and countdown every second
    });
  }

  void _updateNextPrayer() {
    final now = DateTime.now();

    String activePrayerName = '';
    String countdown = '';
    String status = '';

    String upcomingPrayerName = '';
    DateTime? upcomingPrayerTime;

    for (var entry in _prayerTimeDates.entries) {
      final prayer = entry.key;
      final time = entry.value;
      final deadline = time.add(Duration(minutes: _getPrayerDeadline(prayer)));

      log(
        'Checking $prayer: Time=${DateFormat('hh:mm a').format(time)}, Deadline=${DateFormat('hh:mm a').format(deadline)}, Now=${DateFormat('hh:mm a').format(now)}',
      );

      if (now.isBefore(time)) {
        // This is a future prayer
        if (upcomingPrayerTime == null || time.isBefore(upcomingPrayerTime)) {
          upcomingPrayerTime = time;
          upcomingPrayerName = prayer;
          log("this is from 254 $upcomingPrayerName");
        }
      } else if (now.isBefore(deadline)) {
        // Currently within this prayer's deadline
        activePrayerName = prayer;
        countdown = _formatDuration(deadline.difference(now));
        status = 'Pray within';
      }
    }

    // If not within any deadline, the next prayer is purely upcoming
    if (activePrayerName == '' && upcomingPrayerTime != null) {
      activePrayerName = upcomingPrayerName;
      countdown = _formatDuration(upcomingPrayerTime.difference(now));
      status = 'Time until prayer';
    }

    log('Active Prayer: $activePrayerName');
    log('Next Countdown: $countdown');
    log('Status: $status');
    log('Next prayer: $upcomingPrayerName');

    setState(() {
      _nextPrayer =
          upcomingPrayerName != '' ? upcomingPrayerName : 'No upcoming prayers';

      if (upcomingPrayerName != '') {
        // Always use next prayer countdown only
        _countdownMessage = _formatDuration(
          _prayerTimeDates[upcomingPrayerName]!.difference(now),
        );
        _prayerCountdown = 'Time until prayer';
      } else {
        _countdownMessage = '';
        _prayerCountdown = '';
      }

      log('Next prayer 280: $_nextPrayer');
      log('countdown message: $_countdownMessage');
      log('prayer countdown: $_prayerCountdown');
    });
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    return "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  int _getPrayerDeadline(String prayerName) {
    // Set an appropriate deadline for each prayer.
    switch (prayerName) {
      case 'Fajr':
        return 60;
      case 'Dhuhr':
        return 180;
      case 'Asr':
        return 180;
      case 'Maghrib':
        return 30;
      case 'Isha':
        return 240;
      default:
        return 10;
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check if location permissions are granted
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    // Get current location
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      // const Color(0xFF082032),
      appBar: AppBar(
        title: Text(
          'Prayer Times',
          style: AppTextStyles.midheading.copyWith(fontSize: 25),
        ),
        backgroundColor: AppColors.green,
        // const Color(0xFF1C2A39),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Show Lottie animation while data is loading
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: Lottie.asset(
                      'assets/videos/masjid.json', // Replace with the path to your Lottie file
                      width: 100,
                      height: 100,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              if (!_isLoading)
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "Next Salah: $_nextPrayer",
                        style: AppTextStyles.midheading,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Countdown: $_countdownMessage",
                        style: AppTextStyles.smallheading.copyWith(
                          fontSize: 20,
                          color: AppColors.textdark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _prayerTimeDates.length,
                          itemBuilder: (context, index) {
                            final prayer = _prayerTimeDates.keys.elementAt(
                              index,
                            );
                            final prayerTime =
                                _prayerTimeDates[prayer] ?? DateTime.now();
                            final deadline = prayerTime.add(
                              Duration(minutes: _getPrayerDeadline(prayer)),
                            );
                            final now = DateTime.now();

                            // Defensive null-safe initialization
                            _showCheckbox[prayer] =
                                _showCheckbox[prayer] ?? false;
                            _prayerDone[prayer] = _prayerDone[prayer] ?? false;

                            final showCheckbox = _showCheckbox[prayer]!;
                            final prayerDone = _prayerDone[prayer]!;

                            Color cardColor = Colors.white70;
                            String cardText = '';
                            final formattedPrayerTime = DateFormat(
                              'hh:mm a',
                            ).format(prayerTime);

                            if (prayerDone) {
                              cardColor = Colors.grey;
                              cardText = 'Salah done';
                            } else if (prayer == _nextPrayer) {
                              cardColor = Colors.green;
                              cardText = 'Next Prayer in: $_countdownMessage';
                            } else if (now.isAfter(deadline)) {
                              cardColor = Colors.red;
                              cardText = 'Kala\'h';
                            } else if (now.isAfter(prayerTime)) {
                              cardColor = Colors.orange;
                              cardText =
                                  'Deadline in: ${_formatDuration(deadline.difference(now))}';
                            } else {
                              cardColor = Colors.blue;
                              cardText = 'Upcoming Prayer';
                            }

                            return Card(
                              color: cardColor,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _showCheckbox[prayer] = !showCheckbox;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          prayer,
                                          style: AppTextStyles.midheading
                                              .copyWith(fontSize: 22),
                                        ),
                                        trailing: Text(
                                          formattedPrayerTime,
                                          style: AppTextStyles.smallheading,
                                        ),
                                        subtitle: Text(
                                          cardText,
                                          style: AppTextStyles.smallheading,
                                        ),
                                      ),
                                      if (now.isAfter(prayerTime))
                                        if (showCheckbox)
                                          Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Checkbox(
                                                  value: prayerDone,
                                                  onChanged: (value) async {
                                                    setState(() {
                                                      _prayerDone[prayer] =
                                                          value!;
                                                    });

                                                    // Get the current date in 'yyyy-MM-dd' format
                                                    final date = DateFormat(
                                                      'yyyy-MM-dd',
                                                    ).format(DateTime.now());

                                                    final prayerStatus = PrayerStatus(
                                                      prayerName:
                                                          prayer, // The name of the prayer (e.g., 'Fajr')
                                                      date:
                                                          date, // Current date
                                                      status:
                                                          value!
                                                              ? 'prayed'
                                                              : 'missed', // 'prayed' if checked, 'missed' if unchecked
                                                    );

                                                    // Insert the prayer status into the database
                                                    await PrayerDBHelper()
                                                        .insertStatus(
                                                          prayerStatus,
                                                        );
                                                  },
                                                  checkColor: Colors.white,
                                                  activeColor: Colors.green,
                                                ),
                                                Text(
                                                  'Done',
                                                  style: AppTextStyles
                                                      .smallheading
                                                      .copyWith(fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
