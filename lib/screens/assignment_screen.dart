import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class AssignmentsScreen extends StatefulWidget {
  @override
  _AssignmentsScreenState createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final List<String> courses = [
    "INFT-3100-02",
    "INFT-3101-02",
    "INFT-3102-02",
    "INFT-3103-01",
    "INFT-3104-04"
  ];

  final TextEditingController titleController = TextEditingController();
  String? selectedCourse;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        backgroundColor: Colors.deepPurple,
      ),
      body: appState.assignments.isEmpty
          ? Center(
        child: Text(
          'No upcoming assignments.',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : Colors.grey,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: appState.assignments.length,
        itemBuilder: (context, index) {
          final assignment = appState.assignments[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.assignment, color: Colors.deepPurple, size: 32),
              title: Text(
                assignment['title'],
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
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    appState.removeAssignment(index);
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAssignmentDialog(context, appState),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddAssignmentDialog(BuildContext context, AppState appState) async {
    await showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Add Assignment',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Assignment Title',
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCourse,
                    items: courses.map((course) {
                      return DropdownMenuItem(
                        value: course,
                        child: Text(
                          course,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCourse = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Course',
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      setState(() {});
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      selectedDate == null
                          ? 'Pick Due Date'
                          : 'Selected: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.deepPurple,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        selectedCourse != null &&
                        selectedDate != null) {
                      appState.addAssignment({
                        'title': titleController.text,
                        'course': selectedCourse,
                        'dueDate': selectedDate!.toLocal().toString().split(' ')[0],
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.deepPurple,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
