import 'package:flutter/material.dart';

class AssignmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assignments')),
      body: Center(
        child: Text(
          'Your Assignments',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
