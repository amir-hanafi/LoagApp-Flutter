import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_product_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> products = [];
  bool isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token == null) {
      print('Token tidak ditemukan.');
      return;
    }

    final url = Uri.parse('http://192.168.1.14:8000/api/products');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        products = data['products'];
        isLoading = false;
      });
    } else {
      print('Gagal memuat produk: ${response.statusCode}');
      print(response.body);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/');
  }

  // Navigasi ke halaman tambah produk
  Future<void> _navigateToAddProduct() async {
    if (token == null) return;

    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductPage(token: token!),
      ),
    );

    if (refresh == true) {
      fetchProducts(); // refresh daftar produk
    }
  }

  // 🔹 Fungsi konfirmasi hapus
  Future<void> _confirmDelete(int productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Apakah kamu yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteProduct(productId);
    }
  }

  // 🔹 Fungsi hapus produk dari API
  Future<void> _deleteProduct(int productId) async {
    if (token == null) return;

    final url = Uri.parse('http://192.168.1.14:8000/api/products/$productId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil dihapus')),
      );
      fetchProducts(); // refresh daftar produk
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus produk: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('Belum ada produk.'))
              : RefreshIndicator(
                  onRefresh: fetchProducts,
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar Produk
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              child: Image.network(
                                product['image_url'] ?? '',
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image, size: 80);
                                },
                              ),
                            ),

                            // Detail Produk + Tombol Hapus
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            product['name'] ?? 'Tanpa nama',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _confirmDelete(product['id']),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(product['description'] ?? '-'),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Rp ${product['price']}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Pemilik: ${product['owner']?['name'] ?? '-'}',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}
