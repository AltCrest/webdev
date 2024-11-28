import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

class TimetableGrid extends StatefulWidget {
  @override
  _TimetableGridState createState() => _TimetableGridState();
}

class _TimetableGridState extends State<TimetableGrid> {
  int currentWeek = 0; // Tracks the current week
  Map<int, Map<int, String>> timetable = {}; // Tracks events by week and cell index
  DateTime weekStartDate = DateTime.now(); // Start date of the current week

  @override
  void initState() {
    super.initState();
    weekStartDate = _calculateWeekStartDate(); // Initialize the first week
    timetable[currentWeek] = {};
  }

  // Calculate the start date of the current week based on `currentWeek`
  DateTime _calculateWeekStartDate() {
    DateTime today = DateTime.now();
    int daysSinceMonday = today.weekday - 1; // Monday = 1, so subtract 1
    return today.subtract(Duration(days: daysSinceMonday)).add(Duration(days: currentWeek * 7));
  }

  // Get the formatted date range (e.g., "20 Nov - 26 Nov")
  String _getFormattedWeekDates() {
    DateTime endDate = weekStartDate.add(Duration(days: 6));
    String start = DateFormat('dd MMM').format(weekStartDate);
    String end = DateFormat('dd MMM').format(endDate);
    return "$start - $end";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Week Navigation Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  currentWeek--;
                  weekStartDate = _calculateWeekStartDate();
                  timetable.putIfAbsent(currentWeek, () => {}); // Initialize week if not present
                });
              },
            ),
            Text(
              _getFormattedWeekDates(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                setState(() {
                  currentWeek++;
                  weekStartDate = _calculateWeekStartDate();
                  timetable.putIfAbsent(currentWeek, () => {}); // Initialize week if not present
                });
              },
            ),
          ],
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8, // 7 days + 1 hour column
              childAspectRatio: 1.5,
            ),
            itemCount: 8 * 25, // 24 hours + header row
            itemBuilder: (context, index) {
              if (index < 8) {
                return _buildHeaderCell(index); // First row: days of the week
              } else if (index % 8 == 0) {
                return _buildHourCell(index ~/ 8); // First column: hours
              } else {
                return _buildTimetableCell(index); // Regular timetable cell
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(int index) {
    if (index == 0) return Container(); // Empty top-left cell
    List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    DateTime dayDate = weekStartDate.add(Duration(days: index - 1));
    String dayLabel = "${days[index - 1]}\n${DateFormat('dd MMM').format(dayDate)}";
    return Container(
      alignment: Alignment.center,
      color: Colors.grey[300],
      child: Text(dayLabel, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildHourCell(int hour) {
    return Container(
      alignment: Alignment.center,
      color: Colors.grey[200],
      child: Text("$hour:00"),
    );
  }

  Widget _buildTimetableCell(int index) {
    String? eventText = timetable[currentWeek]?[index];

    return GestureDetector(
      onTap: () {
        _showEventDialog(index); // Handle adding/editing events
      },
      onLongPress: () {
        setState(() {
          timetable[currentWeek]?.remove(index); // Handle deleting events
        });
      },
      child: Container(
        margin: EdgeInsets.all(1),
        color: eventText == null ? Colors.white : Colors.blue[100],
        child: Center(
          child: Text(eventText ?? ""),
        ),
      ),
    );
  }

  void _showEventDialog(int index) {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add/Edit Event'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Enter event details'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog without saving
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  timetable[currentWeek]?[index] = _controller.text; // Save event
                });
                Navigator.pop(context); // Close dialog after saving
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
