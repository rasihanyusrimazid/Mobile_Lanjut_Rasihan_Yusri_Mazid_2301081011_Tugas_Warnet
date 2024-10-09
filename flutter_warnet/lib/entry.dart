import 'package:flutter/material.dart';
import 'hasil.dart';

class EntryForm extends StatefulWidget {
  @override
  _EntryFormState createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final _formKey = GlobalKey<FormState>();

  String kodePelanggan = '';
  String namaPelanggan = '';
  String? jenisPelanggan;
  double jamMasuk = 0;
  double jamKeluar = 0;

  List<String> pelangganOptions = ['VIP', 'GOLD'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Pelanggan'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Section: Pelanggan
              Text('Pelanggan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              
              // Kode Pelanggan Input
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Kode Pelanggan',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    kodePelanggan = value;
                  });
                },
              ),
              SizedBox(height: 16.0),

              // Nama Pelanggan Input
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nama Pelanggan',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    namaPelanggan = value;
                  });
                },
              ),
              SizedBox(height: 16.0),

              // Jenis Pelanggan Dropdown
              Text('Jenis Pelanggan', style: TextStyle(fontSize: 16)),
              DropdownButtonFormField<String>(
                value: jenisPelanggan,
                hint: Text('Pilih Jenis Pelanggan'),
                items: pelangganOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    jenisPelanggan = newValue!;
                  });
                },
                validator: (value) => value == null ? 'Pilih Jenis Pelanggan' : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),

              // Jam Masuk Input
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Jam Masuk',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    jamMasuk = double.tryParse(value) ?? 0;
                  });
                },
              ),
              SizedBox(height: 16.0),

              // Jam Keluar Input
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Jam Keluar',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    jamKeluar = double.tryParse(value) ?? 0;
                  });
                },
              ),
              SizedBox(height: 20),

              // Proceed Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HasilForm(
                            kodePelanggan: kodePelanggan,
                            namaPelanggan: namaPelanggan,
                            jenisPelanggan: jenisPelanggan!,
                            jamMasuk: jamMasuk,
                            jamKeluar: jamKeluar,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text('Masuk ke Hasil', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}