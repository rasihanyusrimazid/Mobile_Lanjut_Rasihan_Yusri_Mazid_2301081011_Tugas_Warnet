import 'package:flutter/material.dart';
import 'login.dart';
import 'home.dart';
import 'book_details_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/bookDetails': (context) => BookDetailsScreen(),
      },
    );
  }
}
