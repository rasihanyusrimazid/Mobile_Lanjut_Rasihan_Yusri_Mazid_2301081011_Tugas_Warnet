import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnggotaPage extends StatefulWidget {
  const AnggotaPage({super.key});

  @override
  State<AnggotaPage> createState() => _AnggotaPageState();
}

class _AnggotaPageState extends State<AnggotaPage> {
  List<dynamic> anggotaList = [];
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk form
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  String _jenisKelamin = 'L';

  @override
  void initState() {
    super.initState();
    fetchAnggota();
  }

  Future<void> fetchAnggota() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/pustaka/database_pustaka/anggota.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            anggotaList = data['data'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching anggota: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteAnggota(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost/pustaka/database_pustaka/anggota.php?id=$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          fetchAnggota();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anggota berhasil dihapus')),
          );
        }
      }
    } catch (e) {
      print('Error deleting anggota: $e');
    }
  }

  void _showAddDialog() {
    // Reset form
    _nimController.clear();
    _namaController.clear();
    _alamatController.clear();
    _jenisKelamin = 'L';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah Anggota'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nimController,
                      decoration: const InputDecoration(labelText: 'NIM'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'NIM tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(labelText: 'Nama'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _alamatController,
                      decoration: const InputDecoration(labelText: 'Alamat'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _jenisKelamin,
                      decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                      items: const [
                        DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                        DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _jenisKelamin = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final response = await http.post(
                          Uri.parse('http://localhost/pustaka/database_pustaka/anggota.php'),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode({
                            'nim': _nimController.text,
                            'nama': _namaController.text,
                            'alamat': _alamatController.text,
                            'jenis_kelamin': _jenisKelamin,
                          }),
                        );

                        if (response.statusCode == 200) {
                          final data = json.decode(response.body);
                          if (data['success']) {
                            Navigator.pop(context);
                            fetchAnggota();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Anggota berhasil ditambahkan')),
                            );
                          }
                        }
                      } catch (e) {
                        print('Error adding anggota: $e');
                      }
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDialog(Map<String, dynamic> anggota) {
    _nimController.text = anggota['nim'].toString();
    _namaController.text = anggota['nama'].toString();
    _alamatController.text = anggota['alamat'].toString();
    _jenisKelamin = anggota['jenis_kelamin'].toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Anggota'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nimController,
                      decoration: const InputDecoration(labelText: 'NIM'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'NIM tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(labelText: 'Nama'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _alamatController,
                      decoration: const InputDecoration(labelText: 'Alamat'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _jenisKelamin,
                      decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                      items: const [
                        DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                        DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _jenisKelamin = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final response = await http.put(
                          Uri.parse('http://localhost/pustaka/database_pustaka/anggota.php'),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode({
                            'id': anggota['id'],
                            'nim': _nimController.text,
                            'nama': _namaController.text,
                            'alamat': _alamatController.text,
                            'jenis_kelamin': _jenisKelamin,
                          }),
                        );

                        if (response.statusCode == 200) {
                          final data = json.decode(response.body);
                          if (data['success']) {
                            Navigator.pop(context);
                            fetchAnggota();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Anggota berhasil diupdate')),
                            );
                          }
                        }
                      } catch (e) {
                        print('Error updating anggota: $e');
                      }
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Anggota'),
        elevation: 2,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : anggotaList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, 
                           size: 80, 
                           color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data anggota',
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
                  itemCount: anggotaList.length,
                  itemBuilder: (context, index) {
                    final anggota = anggotaList[index];
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
                                CircleAvatar(
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    anggota['nama']?.toString().substring(0, 1).toUpperCase() ?? 'A',
                                    style: TextStyle(
                                      color: Colors.blue[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        anggota['nama']?.toString() ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'NIM: ${anggota['nim']?.toString() ?? ''}',
                                          style: TextStyle(
                                            color: Colors.blue[900],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, 
                                     size: 16, 
                                     color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    anggota['alamat']?.toString() ?? '',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.person_outline, 
                                     size: 16, 
                                     color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  anggota['jenis_kelamin'] == 'L' 
                                      ? 'Laki-laki' 
                                      : 'Perempuan',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit'),
                                  onPressed: () => _showEditDialog(anggota),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Hapus'),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Konfirmasi'),
                                      content: const Text(
                                          'Apakah Anda yakin ingin menghapus data ini?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            deleteAnggota(
                                                int.parse(anggota['id'].toString()));
                                          },
                                          child: const Text('Hapus'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
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
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Anggota'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    super.dispose();
  }
}
