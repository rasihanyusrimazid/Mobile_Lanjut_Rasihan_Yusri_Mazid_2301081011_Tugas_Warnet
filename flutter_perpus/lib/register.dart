import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6A4C93), // Adjust for your desired background color
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20.0), // Consistent padding value
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5.0,
                blurRadius: 7.0,
                offset: Offset(0, 3.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Restricts column size
            children: [
              Text(
                'Register\nSebelum Mulai',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  
                ),
              ),
              SizedBox(height: 20.0), // Consistent spacing
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  // Add your registration logic here
                  print('Register button pressed');
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}