import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class AddProductPage extends StatefulWidget {
  final String token; // menerima token dari HomePage

  const AddProductPage({super.key, required this.token});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _uploadProduct() async {
    if (_nameController.text.isEmpty ||
        _descController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom wajib diisi.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final url = Uri.parse('http://192.168.2.181:8000/api/products');

    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${widget.token}'
      ..fields['name'] = _nameController.text
      ..fields['description'] = _descController.text
      ..fields['price'] = _priceController.text;

    // ✅ Upload gambar sesuai platform
    if (!kIsWeb) {
      // Android/iOS
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
          filename: path.basename(_imageFile!.path),
        ),
      );
    } else {
      // Flutter Web
      final bytes = await _imageFile!.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: path.basename(_imageFile!.name),
        ),
      );
    }

    final response = await request.send();

    setState(() {
      _isUploading = false;
    });

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil diupload!')),
      );
      Navigator.pop(context, true); // kembali ke HomePage dan refresh
    } else {
      final resBody = await response.stream.bytesToString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload: $resBody')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Produk'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pilih Gambar'),
            ),
            const SizedBox(height: 10),
            if (_imageFile != null)
              Center(
                child: kIsWeb
                    ? Image.network(_imageFile!.path, height: 150)
                    : Image.file(File(_imageFile!.path), height: 150),
              ),
            const SizedBox(height: 20),
            Center(
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _uploadProduct,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Upload Produk'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
