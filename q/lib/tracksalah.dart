import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:q/constants.dart';
import 'package:q/prayerSDBhelper.dart';
import 'package:table_calendar/table_calendar.dart';

class Tracksalah extends StatefulWidget {
  const Tracksalah({super.key});

  @override
  State<Tracksalah> createState() => _TracksalahState();
}

class _TracksalahState extends State<Tracksalah> {
  Map<String, Map<String, String>> prayerStatusByDate = {};
  final List<String> salahList = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  Map<String, int> streaks = {}; // Salah name -> streak count
  late DateTime selectedDay;
  late DateTime focusedDay;
  late PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadPrayerData();
  }

  Future<void> _loadPrayerData() async {
    final dbHelper = PrayerDBHelper();
    final allStatuses = await dbHelper.fetchAllStatuses();

    Map<String, Map<String, String>> grouped = {};
    for (var status in allStatuses) {
      grouped.putIfAbsent(status.date, () => {});
      grouped[status.date]![status.prayerName] = status.status;
    }
    final sortedDates = grouped.keys.toList()..sort(); // ensure ascending order
    final lastPageIndex = sortedDates.length - 1;
    setState(() {
      prayerStatusByDate = grouped;
      streaks = _calculateStreaks();
      _currentPage = lastPageIndex;
      _pageController = PageController(initialPage: lastPageIndex);
    });
  }

  Map<String, int> _getDailyCompletionCounts() {
    return {
      for (var date in prayerStatusByDate.keys)
        date:
            salahList
                .where((salah) => prayerStatusByDate[date]?[salah] == 'prayed')
                .length,
    };
  }

  // Color _getColorForCount(int count) {
  //   if (count >= 5) return Colors.green[900]!;
  //   if (count == 4) return Colors.green[700]!;
  //   if (count == 3) return Colors.green[500]!;
  //   if (count == 2) return Colors.green[300]!;
  //   if (count == 1) return Colors.green[100]!;
  //   return Colors.grey[300]!;
  // }
  Color _getColorForCount(int count) {
    if (count >= 5) return const Color(0xFF00393A); // Darkest shade
    if (count == 4) return const Color(0xFF004B4D); // Darker
    if (count == 3) return const Color(0xFF00585A); // Base color
    if (count == 2) return const Color(0xFF337E80); // Lighter
    if (count == 1) return const Color(0xFF66A4A6); // Lightest
    return const Color(0xFFE0E0E0); // For 0 count - light grey
  }

  Map<String, int> _calculateStreaks() {
    final sortedDates =
        prayerStatusByDate.keys.toList()
          ..sort((a, b) => b.compareTo(a)); // newest first
    Map<String, int> localStreaks = {for (var salah in salahList) salah: 0};

    for (var salah in salahList) {
      for (var date in sortedDates) {
        final status = prayerStatusByDate[date]?[salah];
        if (status == 'prayed') {
          localStreaks[salah] = localStreaks[salah]! + 1;
        } else {
          break; // streak ends
        }
      }
    }

    return localStreaks;
  }

  @override
  Widget build(BuildContext context) {
    final dates = prayerStatusByDate.keys.toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text("Salah Tracker", style: AppTextStyles.contentblack),
        backgroundColor: AppColors.cream,
      ),
      body:
          prayerStatusByDate.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: dates.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final date = dates[index];
                        final salahStatus = prayerStatusByDate[date] ?? {};
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.textdark,
                                  blurRadius: 2,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Date: $date",
                                  style: AppTextStyles.contentblack.copyWith(
                                    color: AppColors.cream,
                                  ),
                                ),

                                // const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children:
                                      salahList.map((salah) {
                                        final date = dates[_currentPage];
                                        final salahStatus =
                                            prayerStatusByDate[date] ?? {};
                                        final status =
                                            salahStatus[salah] ?? 'missed';
                                        final bool prayed = status == 'prayed';
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                prayed
                                                    ? Icons.check_circle
                                                    : Icons.cancel,
                                                color:
                                                    prayed
                                                        ? Colors.green
                                                        : Colors.red,
                                                size: 28,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                salah,
                                                style: AppTextStyles
                                                    .contentblack
                                                    .copyWith(
                                                      fontSize: 15,
                                                      color: AppColors.textdark,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(dates.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        width: _currentPage == index ? 10 : 6,
                        height: _currentPage == index ? 10 : 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentPage == index
                                  ? AppColors.green
                                  : AppColors.green.withOpacity(0.4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  // _buildStreakChips(),
                  _buildPagedHeatmap(),
                  const SizedBox(height: 16),
                  lineplot(),
                  const SizedBox(height: 16),
                  _buildLegend(),
                  const SizedBox(height: 16),
                ],
              ),
    );
  }

  Widget lineplot() {
    final dates = prayerStatusByDate.keys.toList()..sort();

    final prayedCounts = <FlSpot>[];
    final missedCounts = <FlSpot>[];

    for (int i = 0; i < dates.length; i++) {
      final date = dates[i];
      final salahStatuses = prayerStatusByDate[date] ?? {};

      int prayed = salahStatuses.values.where((s) => s == 'prayed').length;
      int missed = salahList.length - prayed;

      prayedCounts.add(FlSpot(i.toDouble(), prayed.toDouble()));
      missedCounts.add(FlSpot(i.toDouble(), missed.toDouble()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text("Recent Salah", style: AppTextStyles.contentblack),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.textblack,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: salahList.length.toDouble(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < dates.length) {
                          final formatted = dates[index].substring(5); // MM-DD
                          return Text(
                            formatted,
                            style: AppTextStyles.smallheading.copyWith(
                              fontSize: 10,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 20,
                      getTitlesWidget:
                          (value, meta) => Text(
                            value.toInt().toString(),
                            style: AppTextStyles.smallheading.copyWith(
                              fontSize: 10,
                            ),
                          ),
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine:
                      (value) =>
                          FlLine(color: AppColors.textdark, strokeWidth: 0.2),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppColors.textdark, width: 1),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: prayedCounts,
                    isCurved: false,
                    color: AppColors.lightgreen,
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: missedCounts,
                    isCurved: false,
                    color: AppColors.red,
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    // tooltipBgColor: Colors.white,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final label =
                            spot.bar.color == Colors.green
                                ? "Prayed"
                                : "Missed";
                        return LineTooltipItem(
                          "$label: ${spot.y.toInt()}",
                          AppTextStyles.contentblack,
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPagedHeatmap() {
    final completionCounts = _getDailyCompletionCounts();
    selectedDay = DateTime.now();
    focusedDay = DateTime.now(); // Map<String, int>
    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: 4));
    final fullDates = List.generate(
      14,
      (i) => startDate.add(Duration(days: i)),
    );

    // Weekday alignment: Sunday = 0, Monday = 1, ..., Saturday = 6
    final startPadding = fullDates.first.weekday % 7;
    final fullCalendar =
        <DateTime?>[]; // Use a growable list instead of a fixed-length list
    fullCalendar.addAll(
      List<DateTime?>.filled(startPadding, null),
    ); // Add padding
    fullCalendar.addAll(fullDates); // Add actual dates

    // Ensure there are exactly 14 elements in the list
    while (fullCalendar.length < 14) {
      fullCalendar.add(null);
    }

    return Column(
      children: [
        TableCalendar(
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: AppTextStyles.smallheading.copyWith(
              color: AppColors.textblack,
            ),
            weekendStyle: AppTextStyles.smallheading.copyWith(
              color: AppColors.textdark,
            ),
          ),

          calendarFormat: CalendarFormat.twoWeeks,
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: AppTextStyles.contentblack,
          ),

          firstDay: DateTime.utc(2025, 1, 1),
          lastDay: DateTime.utc(2025, 12, 31),
          focusedDay: focusedDay,
          availableGestures: AvailableGestures.horizontalSwipe,
          availableCalendarFormats: const {CalendarFormat.twoWeeks: ''},
          // selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          onDaySelected: (day, focusedDay) {
            setState(() {
              this.selectedDay = day;
              this.focusedDay = focusedDay;
            });
          },

          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final dateStr = day.toIso8601String().split('T').first;
              final count = completionCounts[dateStr];
              final bgColor =
                  count != null ? _getColorForCount(count) : AppColors.cream;

              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: AppTextStyles.smallheading.copyWith(
                    color: AppColors.textblack,
                  ),
                ),
              );
            },
            todayBuilder: (context, day, focusedDay) {
              final dateStr = day.toIso8601String().split('T').first;
              final count = completionCounts[dateStr];
              final bgColor =
                  count != null ? _getColorForCount(count) : AppColors.cream;
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: AppColors.textblack, width: 2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: AppTextStyles.smallheading.copyWith(
                    color: AppColors.textblack,
                  ),
                ),
              );
            },
          ),
          calendarStyle: const CalendarStyle(outsideDaysVisible: false),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, color: AppColors.lightgreen, size: 10),
          SizedBox(width: 4),
          Text(
            "Prayed",
            style: AppTextStyles.smallheading.copyWith(
              color: AppColors.textdark,
            ),
          ),
          SizedBox(width: 16),
          Icon(Icons.circle, color: AppColors.red, size: 10),
          SizedBox(width: 4),
          Text(
            "Missed",
            style: AppTextStyles.smallheading.copyWith(
              color: AppColors.textdark,
            ),
          ),
        ],
      ),
    );
  }
}
