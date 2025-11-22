import 'dart:convert';
import 'dart:io' show File; // hanya untuk Android/iOS
import 'package:flutter/foundation.dart'; // untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProductPage extends StatefulWidget {
  final int productId;
  final String name;
  final String description;
  final String price;
  final String image;

  const EditProductPage({
    super.key,
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  XFile? _pickedImage; // <-- gunakan XFile, bukan File
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _descriptionController = TextEditingController(text: widget.description);
    _priceController = TextEditingController(text: widget.price);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final url = Uri.parse('http://10.187.243.197:8000/api/products/${widget.productId}');
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = _nameController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['price'] = _priceController.text;

    if (_pickedImage != null) {
      if (kIsWeb) {
        // Flutter Web: kirim dengan bytes
        final bytes = await _pickedImage!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: _pickedImage!.name,
        ));
      } else {
        // Android/iOS: kirim dengan path file
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _pickedImage!.path,
        ));
      }
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil diperbarui')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui produk: $responseBody')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (value) =>
                    value!.isEmpty ? 'Nama produk wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (value) =>
                    value!.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Harga wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              // --- Gambar Produk ---
              GestureDetector(
                onTap: _pickImage,
                child: _pickedImage != null
                    ? (kIsWeb
                        ? Image.network(
                            _pickedImage!.path,
                            height: 150,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image, size: 100),
                          )
                        : Image.file(
                            File(_pickedImage!.path),
                            height: 150,
                          ))
                    : Image.network(
                        widget.image.startsWith('http')
                            ? widget.image
                            : 'http://10.187.243.197:8000/storage/${widget.image}',
                        height: 150,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100),
                      ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProduct,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


