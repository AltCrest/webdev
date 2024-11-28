import 'package:flutter/material.dart';
import '../widgets/timetable_grid.dart';

class TimetableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Timetable')),
      body: TimetableGrid(),
    );
  }
}
