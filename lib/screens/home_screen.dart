import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int weekOffset = 0; // 0 for current week, positive for future weeks

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                if (weekOffset > 0) weekOffset--;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                weekOffset++;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Events Overview
            _buildSectionTitle('This Week\'s Events', Icons.event_note, isDarkMode),
            const SizedBox(height: 8),
            _getWeeklyEvents(appState, weekOffset: weekOffset).isEmpty
                ? _buildEmptyMessage('No events scheduled for this week.', isDarkMode)
                : _buildEventOverview(appState, isDarkMode),
            const SizedBox(height: 16),

            // Upcoming Assignments
            _buildSectionTitle('Upcoming Assignments', Icons.assignment, isDarkMode),
            const SizedBox(height: 8),
            appState.assignments.isEmpty
                ? _buildEmptyMessage('No upcoming assignments.', isDarkMode)
                : _buildAssignmentOverview(appState, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDarkMode) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMessage(String message, bool isDarkMode) {
    return Center(
      child: Text(
        message,
        style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.grey),
      ),
    );
  }

  Widget _buildEventOverview(AppState appState, bool isDarkMode) {
    final weeklyEvents = _getWeeklyEvents(appState, weekOffset: weekOffset);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: weeklyEvents.length.clamp(0, 5),
      itemBuilder: (context, index) {
        final event = weeklyEvents[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.event, color: Colors.deepPurple, size: 32),
            title: Text(
              event['event'] ?? '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              'Day: ${event['day']} (${event['date']})\nTime: ${event['time']}',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        );
      },
    );
  }

  List<Map<String, String>> _getWeeklyEvents(AppState appState, {int weekOffset = 0}) {
    List<Map<String, String>> events = [];
    DateTime now = DateTime.now();
    DateTime weekStart = now.subtract(Duration(days: now.weekday - 1)).add(Duration(days: 7 * weekOffset)); // Start of the week
    DateTime weekEnd = weekStart.add(const Duration(days: 6)); // End of the week

    List<String> keysToRemove = []; // To keep track of outdated keys

    appState.timetable.forEach((key, value) {
      try {
        // Parse the key manually
        if (key.length == 10 && RegExp(r'^\d{10}$').hasMatch(key)) {
          int year = int.parse(key.substring(0, 4));
          int month = int.parse(key.substring(4, 6));
          int day = int.parse(key.substring(6, 8));
          int hour = int.parse(key.substring(8, 10));

          DateTime eventDate = DateTime(year, month, day, hour);

          if (eventDate.isBefore(now)) {
            // Mark past events for removal
            keysToRemove.add(key);
          } else if (eventDate.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
              eventDate.isBefore(weekEnd.add(const Duration(days: 1)))) {
            String dayName = DateFormat('EEEE').format(eventDate); // Day name
            String date = DateFormat('dd MMM yyyy').format(eventDate); // Date
            String time = DateFormat('HH:mm').format(eventDate);  // Time
            events.add({'day': dayName, 'date': date, 'time': time, 'event': value});
          }
        }
      } catch (e) {
        // Handle parsing errors silently
      }
    });

    // Remove outdated events from AppState
    for (String key in keysToRemove) {
      appState.removeEvent(key); // This should call notifyListeners in AppState
    }

    // Sort events by day and time
    events.sort((a, b) {
      final dayA = a['day'] ?? '';
      final dayB = b['day'] ?? '';
      final timeA = a['time'] ?? '0:00';
      final timeB = b['time'] ?? '0:00';

      if (dayA == dayB) {
        return timeA.compareTo(timeB);
      }
      return dayA.compareTo(dayB);
    });

    return events;
  }

  Widget _buildAssignmentOverview(AppState appState, bool isDarkMode) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appState.assignments.length.clamp(0, 5),
      itemBuilder: (context, index) {
        final assignment = appState.assignments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.assignment_turned_in, color: Colors.deepPurple, size: 32),
            title: Text(
              assignment['title'] ?? '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              'Course: ${assignment['course']}\nDue: ${assignment['dueDate']}',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        );
      },
    );
  }
}
