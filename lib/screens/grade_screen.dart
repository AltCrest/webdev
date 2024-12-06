import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class GradesScreen extends StatefulWidget {
  @override
  _GradesScreenState createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final List<String> courses = [
    "INFT-3100-02",
    "INFT-3101-02",
    "INFT-3102-02",
    "INFT-3103-01",
    "INFT-3104-04"
  ];

  final TextEditingController assignmentController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  String? selectedCourse;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grades'),
        backgroundColor: Colors.deepPurple,
      ),
      body: appState.grades.isEmpty
          ? Center(
        child: Text(
          'No grades available.',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : Colors.grey,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: appState.grades.length,
        itemBuilder: (context, index) {
          final grade = appState.grades[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.grade, color: Colors.deepPurple, size: 32),
              title: Text(
                grade['assignment'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                'Course: ${grade['course']}\nGrade: ${grade['grade']}%',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    appState.removeGrade(index);
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGradeDialog(context, appState),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddGradeDialog(BuildContext context, AppState appState) async {
    await showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Add Grade',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: assignmentController,
                    decoration: InputDecoration(
                      labelText: 'Assignment Name',
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
                  TextField(
                    controller: gradeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Grade (%)',
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
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
                    if (assignmentController.text.isNotEmpty &&
                        selectedCourse != null &&
                        gradeController.text.isNotEmpty) {
                      final grade = int.tryParse(gradeController.text.trim()) ?? 0;
                      if (grade > 0) {
                        appState.addGrade({
                          'assignment': assignmentController.text,
                          'course': selectedCourse,
                          'grade': grade,
                        });
                        Navigator.of(context).pop();
                      }
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
