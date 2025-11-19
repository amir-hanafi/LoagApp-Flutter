import 'package:flutter/material.dart';
import 'package:loagapps/pages/detail_page.dart';
import 'package:loagapps/pages/edit_product_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_product_page.dart';

class DetailPage extends StatelessWidget {
  final Map product; // data produk (Map) dari list_page
  final String token;

  const DetailPage({super.key, required this.product, required this.token});

  String _safeString(dynamic v, [String fallback = '-']) {
    if (v == null) return fallback;
    return v.toString();
  }

  Widget _buildNetworkImage(String? url, {double? height = 220}) {
    if (url == null || url.isEmpty) {
      return Container(
        height: height,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image_not_supported, size: 64)),
      );
    }
    return Image.network(
      url,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.broken_image, size: 64)),
        );
      },
    );
  }

  Future<void> _deleteProduct(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus Produk'),
      content: const Text('Yakin ingin menghapus produk ini?'),
      actions: [
        TextButton(
          child: const Text('Batal'),
          onPressed: () => Navigator.pop(context, false),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Hapus'),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  final url = Uri.parse(
      'http://192.168.1.6:8000/api/products/${product['id']}');

  final response = await http.delete(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    Navigator.pop(context, true); // <-- kembali ke ListPage + refresh
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk berhasil dihapus")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal menghapus: ${response.body}")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    // Ambil field dengan aman
    final String name = _safeString(product['name'], 'Tidak ada nama');
    final String description = _safeString(product['description'], 'Tidak ada deskripsi');
    final String price = _safeString(product['price'], '0');
    final String imageUrl = _safeString(product['image_url'], '');
    final Map? owner = product['owner'] is Map ? product['owner'] as Map : null;
    final String ownerName = owner != null ? _safeString(owner['name'], '-') : '-';
    final String ownerProfile = owner != null ? _safeString(owner['profile_photo'], '') : '';
    final String province = owner != null ? _safeString(owner['province'], '-') : '-';
    final String city = owner != null ? _safeString(owner['city'], '-') : '-';

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Product"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto produk (aman)
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildNetworkImage(imageUrl, height: 220),
            ),
            const SizedBox(height: 16),

            // Nama + Harga
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rp ${price}',
                  style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w600),
                ),
                Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    final refresh = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProductPage(
                          productId: product['id'],
                          name: product['name'],
                          description: product['description'],
                          price: product['price'].toString(),
                          image: product['image'],
                        ),
                      ),
                    );

                    if (refresh == true) {
                      Navigator.pop(context, true); 
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Produk'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _deleteProduct(context),
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus Produk'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                
                
              ],
            ),
            const SizedBox(height: 16),

            const Text('Deskripsi :', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 20),

            Row(
              children: [
                const Text('Informasi Pemilik : ',style: TextStyle(fontWeight: FontWeight.bold)),
                Text(ownerName),
                Spacer(),
                Column(
                  children: [
                    SizedBox(height: 100),
                    Text(
                      "Alamat: ${product['owner']['province']}, ${product['owner']['city']}",
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
