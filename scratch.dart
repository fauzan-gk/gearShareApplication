import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: RadioGroup<String>(
        groupValue: 'A',
        onChanged: (v) {},
        child: Column(
          children: [
            RadioListTile<String>(
              value: 'A',
              title: Text('A'),
              activeColor: Colors.red,
            ),
          ],
        ),
      ),
    ),
  ));
}
