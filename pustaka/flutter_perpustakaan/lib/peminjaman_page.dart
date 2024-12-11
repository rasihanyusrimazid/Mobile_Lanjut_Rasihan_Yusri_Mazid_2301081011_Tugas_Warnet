import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class PeminjamanPage extends StatefulWidget {
  @override
  _PeminjamanPageState createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  List<Map<String, dynamic>> peminjaman = [];
  bool isLoading = true;
  
  // Controllers for the add/edit form
  final _formKey = GlobalKey<FormState>();
  TextEditingController tanggalPinjamController = TextEditingController();
  TextEditingController tanggalKembaliController = TextEditingController();
  TextEditingController anggotaController = TextEditingController();
  TextEditingController bukuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPeminjaman();
  }

  // Fetch all loans
  Future<void> fetchPeminjaman() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://localhost/pustaka/database_pustaka/peminjaman.php')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            peminjaman = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() => isLoading = false);
    }
  }

  // Add new loan
  Future<void> addPeminjaman(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/pustaka/database_pustaka/peminjaman.php'),
        body: json.encode(data),
        headers: {'Content-Type': 'application/json'},
      );

      final result = json.decode(response.body);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Peminjaman berhasil ditambahkan')),
        );
        fetchPeminjaman();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Delete loan
  Future<void> deletePeminjaman(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost/database_pustaka/peminjaman.php?id=$id'),
      );

      final result = json.decode(response.body);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Peminjaman berhasil dihapus')),
        );
        fetchPeminjaman();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Show form dialog
  void showFormDialog({Map<String, dynamic>? peminjamanData}) {
    if (peminjamanData != null) {
      tanggalPinjamController.text = peminjamanData['tanggal_pinjam'];
      tanggalKembaliController.text = peminjamanData['tanggal_kembali'];
      anggotaController.text = peminjamanData['anggota'].toString();
      bukuController.text = peminjamanData['buku'];
    } else {
      tanggalPinjamController.clear();
      tanggalKembaliController.clear();
      anggotaController.clear();
      bukuController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(peminjamanData == null ? 'Tambah Peminjaman' : 'Edit Peminjaman'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: tanggalPinjamController,
                  decoration: InputDecoration(labelText: 'Tanggal Pinjam'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap isi tanggal pinjam';
                    }
                    return null;
                  },
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      tanggalPinjamController.text = 
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
                TextFormField(
                  controller: tanggalKembaliController,
                  decoration: InputDecoration(labelText: 'Tanggal Kembali'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap isi tanggal kembali';
                    }
                    return null;
                  },
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      tanggalKembaliController.text = 
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
                TextFormField(
                  controller: anggotaController,
                  decoration: InputDecoration(labelText: 'ID Anggota'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap isi ID anggota';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: bukuController,
                  decoration: InputDecoration(labelText: 'Kode Buku'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap isi kode buku';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final data = {
                  if (peminjamanData != null) 'id': peminjamanData['id'],
                  'tanggal_pinjam': tanggalPinjamController.text,
                  'tanggal_kembali': tanggalKembaliController.text,
                  'anggota': int.parse(anggotaController.text),
                  'buku': bukuController.text,
                };
                
                if (peminjamanData == null) {
                  addPeminjaman(data);
                } else {
                  // Add update functionality here if needed
                }
                Navigator.pop(context);
              }
            },
            child: Text(peminjamanData == null ? 'Tambah' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peminjaman Buku'),
        elevation: 2,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : peminjaman.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.library_books_outlined, 
                           size: 80, 
                           color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data peminjaman',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: peminjaman.length,
                  itemBuilder: (context, index) {
                    final item = peminjaman[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.book,
                                    color: Colors.blue[900],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['judul_buku'] ?? 'Unknown Book',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Peminjam: ${item['nama_anggota'] ?? 'Unknown Member'}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Tanggal Pinjam',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['tanggal_pinjam'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                    width: 1,
                                    color: Colors.grey[300],
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Tanggal Kembali',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['tanggal_kembali'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Hapus'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Konfirmasi'),
                                      content: const Text(
                                          'Yakin ingin menghapus peminjaman ini?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            deletePeminjaman(item['id']);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Hapus'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Peminjaman'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
