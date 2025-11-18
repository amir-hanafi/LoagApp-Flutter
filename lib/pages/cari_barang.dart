import 'package:flutter/material.dart';
import 'package:loagapps/pages/detail_cari_barang.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CariBarangPage extends StatefulWidget {
  const CariBarangPage({super.key});

  @override
  State<CariBarangPage> createState() => _CariBarangPageState();
}

class _CariBarangPageState extends State<CariBarangPage> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];

  bool isLoading = true;
  String searchQuery = "";
  String? token;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token == null) return;

    final url = Uri.parse('http://192.168.2.135:8000/api/products');
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
        filteredProducts = products;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  // 🔍 fungsi filter produk
  void filterProducts(String query) {
    final suggestions = products.where((product) {
      final name = product['name'].toString().toLowerCase();
      final price = product['price'].toString();
      final prov = product['owner']['province'].toString().toLowerCase();
      final city = product['owner']['city'].toString().toLowerCase();

      final input = query.toLowerCase();

      return name.contains(input) ||
          price.contains(input) ||
          prov.contains(input) ||
          city.contains(input);
    }).toList();

    setState(() {
      searchQuery = query;
      filteredProducts = suggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cari Barang"),
      ),
      body: Column(
        children: [
          // 🔍 TEXTFIELD SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: filterProducts,
              decoration: InputDecoration(
                hintText: "Cari nama, harga, atau lokasi...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // 📋 LIST CARD PRODUK
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                    ? const Center(
                        child: Text("Tidak ada produk ditemukan."),
                      )
                    : ListView.builder(
  itemCount: filteredProducts.length,
  itemBuilder: (context, index) {
    final product = filteredProducts[index];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailCariBarangPage(
              product: product,
              token: token!,
            ),
          ),
        );
      },

      child: Card(
        margin: const EdgeInsets.all(10),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                product['image_url'] ?? '',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              ),
            ),

            // DETAIL
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Rp ${product['price']}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Alamat: ${product['owner']['province']}, ${product['owner']['city']}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
),

          ),
        ],
      ),
    );
  }
}
