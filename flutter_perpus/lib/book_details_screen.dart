import 'package:flutter/material.dart';

class BookDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4B145B),
      appBar: AppBar(
        backgroundColor: Color(0xFF4B145B),
        elevation: 0,
        title: Text('Detail Buku'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Text('Gambar Buku'),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Eminence in Shadow Vol 1',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'Cid Kagenou memiliki mimpi yang berbeda...',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Fungsi pinjam buku
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: Text('Pinjam', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
