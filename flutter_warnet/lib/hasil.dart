import 'package:flutter/material.dart';

class HasilForm extends StatefulWidget {
  final String kodePelanggan;
  final String namaPelanggan;
  final String jenisPelanggan;
  final double jamMasuk;
  final double jamKeluar;

  HasilForm({
    required this.kodePelanggan,
    required this.namaPelanggan,
    required this.jenisPelanggan,
    required this.jamMasuk,
    required this.jamKeluar,
  });

  @override
  _HasilFormState createState() => _HasilFormState();
}

class _HasilFormState extends State<HasilForm> {
  final double tarifPerJam = 10000;
  double totalBayar = 0;

  @override
  void initState() {
    super.initState();
    calculateTotal();
  }

  void calculateTotal() {
    double lama = widget.jamKeluar - widget.jamMasuk;
    double diskon = 0;

    if (widget.jenisPelanggan == "VIP" && lama > 2) {
      diskon = 0.02;
    } else if (widget.jenisPelanggan == "GOLD" && lama > 2) {
      diskon = 0.05;
    }

    totalBayar = lama * tarifPerJam * (1 - diskon);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Perhitungan'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pelanggan: ${widget.namaPelanggan} (${widget.kodePelanggan})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Displaying Jam Masuk and Jam Keluar
            Text('Jam Masuk: ${widget.jamMasuk}'),
            Text('Jam Keluar: ${widget.jamKeluar}'),
            SizedBox(height: 20),

            // Displaying Total Bill
            Center(
              child: Text(
                'Total Bayar: Rp. ${totalBayar.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}