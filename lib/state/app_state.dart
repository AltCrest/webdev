import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // Timetable State
  Map<String, String> timetable = {}; // Maps cell key (yyyyMMddHH) to event text

  void addEvent(String key, String event) {
    timetable[key] = event;
    notifyListeners();
  }

  void removeEvent(String key) {
    timetable.remove(key);
    notifyListeners(); // Notifies UI of the changes
  }


  // Assignments State
  List<Map<String, dynamic>> assignments = [];

  void addAssignment(Map<String, dynamic> assignment) {
    assignments.add(assignment);
    notifyListeners();
  }

  void removeAssignment(int index) {
    assignments.removeAt(index);
    notifyListeners();
  }

  // Grades State
  List<Map<String, dynamic>> grades = [];

  void addGrade(Map<String, dynamic> grade) {
    grades.add(grade);
    notifyListeners();
  }

  void removeGrade(int index) {
    grades.removeAt(index);
    notifyListeners();
  }

  // Theme State
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
