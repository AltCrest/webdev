import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class TimetableScreen extends StatefulWidget {
  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  int currentWeekOffset = 0; // 0 for current week, 1 for next week
  late DateTime weekStartDate;

  @override
  void initState() {
    super.initState();
    weekStartDate = _calculateWeekStartDate(currentWeekOffset);
  }

  DateTime _calculateWeekStartDate(int weekOffset) {
    DateTime today = DateTime.now();
    int daysSinceMonday = today.weekday - 1; // Monday = 1
    DateTime currentWeekStart = today.subtract(Duration(days: daysSinceMonday));
    return currentWeekStart.add(Duration(days: 7 * weekOffset));
  }

  String _getFormattedWeekRange() {
    DateTime endOfWeek = weekStartDate.add(const Duration(days: 6));
    String start = DateFormat('dd MMM').format(weekStartDate);
    String end = DateFormat('dd MMM').format(endOfWeek);
    return "$start - $end";
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Week Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    if (currentWeekOffset > 0) {
                      currentWeekOffset--;
                      weekStartDate = _calculateWeekStartDate(currentWeekOffset);
                    }
                  });
                },
              ),
              Text(
                _getFormattedWeekRange(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  setState(() {
                    currentWeekOffset++;
                    weekStartDate = _calculateWeekStartDate(currentWeekOffset);
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8, // 7 days + 1 for time column
                childAspectRatio: 1.5,
              ),
              itemCount: 8 * 24, // 8 columns, 24 rows
              itemBuilder: (context, index) {
                if (index < 8) {
                  return _buildHeaderCell(index, isDarkMode);
                } else if (index % 8 == 0) {
                  return _buildHourCell(index ~/ 8, isDarkMode);
                } else {
                  return _buildTimetableCell(appState, index, context, isDarkMode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(int index, bool isDarkMode) {
    if (index == 0) {
      return Container(); // Empty top-left cell
    }
    DateTime dayDate = weekStartDate.add(Duration(days: index - 1));
    String dayLabel = DateFormat('EEE\ndd MMM').format(dayDate);
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
      child: Text(
        dayLabel,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildHourCell(int hour, bool isDarkMode) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
      child: Text(
        '$hour:00',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildTimetableCell(AppState appState, int index, BuildContext parentContext, bool isDarkMode) {
    int day = (index % 8) - 1; // Day index (Monday = 0)
    int hour = index ~/ 8; // Hour of the day
    DateTime cellDate = weekStartDate.add(Duration(days: day, hours: hour));
    String cellKey = DateFormat('yyyyMMddHH').format(cellDate); // Unique key based on date & time
    String? event = appState.timetable[cellKey];

    return GestureDetector(
      onTap: () => _showAddEventDialog(appState, cellKey, parentContext),
      onLongPress: () => appState.removeEvent(cellKey),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: event == null
              ? (isDarkMode ? Colors.grey[900] : Colors.white)
              : (isDarkMode ? Colors.blueGrey[700] : Colors.blue[100]),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: event == null
                ? (isDarkMode ? Colors.grey[800]! : Colors.grey[300]!)
                : (isDarkMode ? Colors.blueGrey[500]! : Colors.blue[300]!),
          ),
        ),
        child: Center(
          child: Text(
            event ?? '',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddEventDialog(AppState appState, String cellKey, BuildContext parentContext) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          title: Text(
            'Add/Edit Event',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter event details',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.deepPurple,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  appState.addEvent(cellKey, text);
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Save',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.deepPurple,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
