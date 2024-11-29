import 'package:flutter/material.dart';

class GradesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Grades')),
      body: Center(
        child: Text(
          'Grades Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}