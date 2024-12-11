import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class Book {
  final String kodeBuku;
  final String judul;
  final String pengarang;
  final String penerbit;
  final String tahun;
  final String? urlGambar;

  Book({
    required this.kodeBuku,
    required this.judul,
    required this.pengarang,
    required this.penerbit,
    required this.tahun,
    this.urlGambar,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      kodeBuku: json['kode_buku'].toString(),
      judul: json['judul'],
      pengarang: json['pengarang'],
      penerbit: json['penerbit'],
      tahun: json['tahun'],
      urlGambar: json['url_gambar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kode_buku': kodeBuku,
      'judul': judul,
      'pengarang': pengarang,
      'penerbit': penerbit,
      'tahun': tahun,
      'url_gambar': urlGambar,
    };
  }
}

class _HomePageState extends State<HomePage> {
  List<Book> books = [];
  bool isLoading = false;
  final String baseUrl = 'http://localhost/pustaka/database_pustaka/buku.php'; // Ganti dengan IP address Anda

  // Controllers for form fields
  final _formKey = GlobalKey<FormState>();
  final _kodeBukuController = TextEditingController();
  final _judulController = TextEditingController();
  final _pengarangController = TextEditingController();
  final _penerbitController = TextEditingController();
  final _tahunController = TextEditingController();
  final _urlGambarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  // Fetch all books
  Future<void> fetchBooks() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            books = (data['data'] as List)
                .map((json) => Book.fromJson(json))
                .toList();
          });
        }
      }
    } catch (e) {
      showSnackBar('Error fetching books: $e');
    }
    setState(() => isLoading = false);
  }

  // Add new book
  Future<void> addBook(Book book) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/pustaka/database_pustaka/buku.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(book.toJson()),
      );
      
      // Debug print untuk melihat response
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          fetchBooks(); // Refresh data setelah berhasil menambah
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Buku berhasil ditambahkan')),
          );
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to add book');
      }
    } catch (e) {
      print('Error adding book: $e'); // Debug print untuk error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Update existing book
  Future<void> updateBook(Book book) async {
    try {
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(book.toJson()),
      );
      
      if (response.statusCode == 200) {
        showSnackBar('Book updated successfully');
        fetchBooks();
      } else {
        showSnackBar('Failed to update book');
      }
    } catch (e) {
      showSnackBar('Error: $e');
    }
  }

  // Delete book
  Future<void> deleteBook(String kodeBuku) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl?kode_buku=$kodeBuku'),
      );
      
      if (response.statusCode == 200) {
        showSnackBar('Book deleted successfully');
        fetchBooks();
      } else {
        showSnackBar('Failed to delete book');
      }
    } catch (e) {
      showSnackBar('Error: $e');
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void clearForm() {
    _kodeBukuController.clear();
    _judulController.clear();
    _pengarangController.clear();
    _penerbitController.clear();
    _tahunController.clear();
    _urlGambarController.clear();
  }

  void showBookForm({Book? book}) {
    if (book != null) {
      _kodeBukuController.text = book.kodeBuku;
      _judulController.text = book.judul;
      _pengarangController.text = book.pengarang;
      _penerbitController.text = book.penerbit;
      _tahunController.text = book.tahun;
      _urlGambarController.text = book.urlGambar ?? '';
    } else {
      clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book == null ? 'Tambah Buku' : 'Edit Buku'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _kodeBukuController,
                  decoration: const InputDecoration(labelText: 'Kode Buku'),
                  enabled: book == null,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Field required' : null,
                ),
                TextFormField(
                  controller: _judulController,
                  decoration: const InputDecoration(labelText: 'Judul'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Field required' : null,
                ),
                TextFormField(
                  controller: _pengarangController,
                  decoration: const InputDecoration(labelText: 'Pengarang'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Field required' : null,
                ),
                TextFormField(
                  controller: _penerbitController,
                  decoration: const InputDecoration(labelText: 'Penerbit'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Field required' : null,
                ),
                TextFormField(
                  controller: _tahunController,
                  decoration: const InputDecoration(labelText: 'Tahun'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Field required' : null,
                ),
                TextFormField(
                  controller: _urlGambarController,
                  decoration: const InputDecoration(
                    labelText: 'URL Gambar',
                    hintText: 'Optional',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newBook = Book(
                  kodeBuku: _kodeBukuController.text,
                  judul: _judulController.text,
                  pengarang: _pengarangController.text,
                  penerbit: _penerbitController.text,
                  tahun: _tahunController.text,
                  urlGambar: _urlGambarController.text.isEmpty 
                      ? null 
                      : _urlGambarController.text,
                );

                if (book == null) {
                  addBook(newBook);
                } else {
                  updateBook(newBook);
                }

                Navigator.pop(context);
              }
            },
            child: Text(book == null ? 'Tambah' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Buku'),
        elevation: 2,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data buku',
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
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          if (book.urlGambar != null && book.urlGambar!.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                book.urlGambar!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        book.judul,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Kode: ${book.kodeBuku}',
                                        style: TextStyle(
                                          color: Colors.blue[900],
                                          fontSize: 12,
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
                                      book.pengarang,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.business, 
                                         size: 16, 
                                         color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      book.penerbit,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.calendar_today, 
                                         size: 16, 
                                         color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      book.tahun,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Edit'),
                                      onPressed: () => showBookForm(book: book),
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
                                          title: const Text('Konfirmasi Hapus'),
                                          content: const Text(
                                              'Apakah Anda yakin ingin menghapus buku ini?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deleteBook(book.kodeBuku);
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
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showBookForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Buku'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    _urlGambarController.dispose();
    _kodeBukuController.dispose();
    _judulController.dispose();
    _pengarangController.dispose();
    _penerbitController.dispose();
    _tahunController.dispose();
    super.dispose();
  }
}