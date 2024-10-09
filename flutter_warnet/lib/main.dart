import 'package:flutter/material.dart';
import 'entry.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warnet Billing',
      home: EntryForm(),
    );
  }
}