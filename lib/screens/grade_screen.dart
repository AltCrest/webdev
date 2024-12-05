import 'package:flutter/material.dart';

class GradesScreen extends StatefulWidget {
  @override
  _GradesScreenState createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  // List of courses
  final List<String> courses = [
    "INFT-3100-02", "INFT-3101-02", "INFT-3102-02", "INFT-3103-01", "INFT-3104-04"
  ];

  // List of grades with course, assignment name, and grade
  final List<Map<String, dynamic>> grades = [
    {'assignment': 'Project', 'course': 'INFT-3101-02', 'grade': 85},
    {'assignment': 'Term Test 2', 'course': 'INFT-3102-02', 'grade': 90},
    {'assignment': 'Assignment 3', 'course': 'INFT-3102-02', 'grade': 92},
    {'assignment': 'Assignment 6', 'course': 'INFT-3100-02', 'grade': 78},
  ];

  @override
  void initState() {
    super.initState();
    _sortGradesByCourse(); // Ensure grades are sorted by course initially
  }

  void _addGrade(String assignment, String course, int grade) {
    setState(() {
      grades.add({'assignment': assignment, 'course': course, 'grade': grade});
      _sortGradesByCourse(); // Re-sort the list after adding a new grade
    });
  }

  void _deleteGrade(int index) {
    setState(() {
      grades.removeAt(index);
    });
  }

  void _sortGradesByCourse() {
    grades.sort((a, b) {
      return a['course'].compareTo(b['course']); // Sort by course name
    });
  }

  Future<void> _showAddGradeDialog() async {
    final TextEditingController assignmentController = TextEditingController();
    final TextEditingController gradeController = TextEditingController();
    String? selectedCourse;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Grade'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Assignment name input
              TextField(
                controller: assignmentController,
                decoration: const InputDecoration(labelText: 'Assignment Name'),
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
              // Grade input
              TextField(
                controller: gradeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Grade'),
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
                final assignment = assignmentController.text;
                final grade = int.tryParse(gradeController.text);
                final course = selectedCourse;

                if (assignment.isNotEmpty && grade != null && course != null) {
                  _addGrade(assignment, course, grade);
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
        title: const Text('Grades'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: grades.length,
        itemBuilder: (context, index) {
          final item = grades[index];
          return Dismissible(
            key: Key(item['assignment']),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _deleteGrade(index);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item['assignment']} deleted')),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              child: ListTile(
                title: Text(
                  item['assignment'],
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
                      'Grade: ${item['grade']}',
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
        onPressed: _showAddGradeDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
