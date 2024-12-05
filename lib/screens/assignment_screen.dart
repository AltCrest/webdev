import 'package:flutter/material.dart';

class AssignmentsScreen extends StatefulWidget {
  @override
  _AssignmentsScreenState createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  // List of available courses
  final List<String> courses = ["INFT-3100-02", "INFT-3101-02", "INFT-3102-02", "INFT-3103-01", "INFT-3104-04"];

  // List of assignments with course and due date
  final List<Map<String, dynamic>> assignments = [
    {'title': 'Project', 'course': 'INFT-3101-02', 'dueDate': '2024-12-06'},
    {'title': 'Term Test 2', 'course': 'INFT-3102-02', 'dueDate': '2024-12-10'},
    {'title': 'Assignment 3', 'course': 'INFT-3102-02', 'dueDate': '2024-12-10'},
    {'title': 'Assignment 6', 'course': 'INFT-3100-02', 'dueDate': '2024-12-13'},
  ];

  @override
  void initState() {
    super.initState();
    _sortAssignmentsByDate(); // Ensure assignments are sorted initially
  }

  void _addAssignment(String title, String course, String dueDate) {
    setState(() {
      assignments.add({'title': title, 'course': course, 'dueDate': dueDate});
      _sortAssignmentsByDate(); // Re-sort the list after adding a new assignment
    });
  }

  void _deleteAssignment(int index) {
    setState(() {
      assignments.removeAt(index);
    });
  }

  void _sortAssignmentsByDate() {
    assignments.sort((a, b) {
      final dateA = DateTime.parse(a['dueDate']);
      final dateB = DateTime.parse(b['dueDate']);
      return dateA.compareTo(dateB);
    });
  }

  Future<void> _showAddAssignmentDialog() async {
    final TextEditingController titleController = TextEditingController();
    DateTime? selectedDate;
    String? selectedCourse;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Assignment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Assignment title input
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Assignment Title'),
              ),
              const SizedBox(height: 16),
              // Course selection dropdown
              DropdownButtonFormField<String>(
                value: selectedCourse,
                items: courses.map((course) {
                  return DropdownMenuItem(
                    value: course,
                    child: Text(course),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCourse = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Select Course'),
              ),
              const SizedBox(height: 16),
              // Due date picker
              ElevatedButton.icon(
                onPressed: () async {
                  selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  setState(() {}); // Update the button text dynamically
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(selectedDate == null
                    ? 'Pick Due Date'
                    : 'Selected: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final title = titleController.text;
                final course = selectedCourse;
                final dueDate = selectedDate?.toLocal().toString().split(' ')[0];

                if (title.isNotEmpty && course != null && dueDate != null) {
                  _addAssignment(title, course, dueDate);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final item = assignments[index];
          return Dismissible(
            key: Key(item['title']),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _deleteAssignment(index);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item['title']} deleted')),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              child: ListTile(
                title: Text(
                  item['title'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course: ${item['course']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Due: ${item['dueDate']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssignmentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
