import 'package:flutter/material.dart';
import 'package:loagapps/pages/detail_page.dart';
import 'package:loagapps/pages/edit_product_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_product_page.dart';
import 'package:url_launcher/url_launcher.dart';


class DetailCariBarangPage extends StatelessWidget {
  final Color kBeige = Color(0xFFDFC49A);
  final Color kDark = Color(0xFF4B4038);
  final BorderRadius kRadius = BorderRadius.all(Radius.circular(14));
  
  final Map product; // data produk (Map) dari list_page
  final String token;

  DetailCariBarangPage({super.key, required this.product, required this.token});

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

  void openWhatsApp(String phone, String productName) async {
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Jika nomor mulai dengan 0 → ganti dengan 62
    if (cleaned.startsWith("0")) {
      cleaned = "62" + cleaned.substring(1);
    }

    // Jika sudah mulai dengan 62 → biarkan
    else if (!cleaned.startsWith("62")) {
      cleaned = "62$cleaned";
    }

    final message = Uri.encodeComponent("Halo!");

    final url = "https://wa.me/$cleaned?text=$message";


    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

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
    final String district = owner != null ? _safeString(owner['district'], '-') : '-';
    final String village = owner != null ? _safeString(owner['village'], '-') : '-';

    return Scaffold(
      appBar: AppBar(title: Text(
        'Detail Barang',
        style: TextStyle(color: Colors.white),
        ), 
        backgroundColor: kDark,),
      body: SingleChildScrollView(
        
        child: Container(
          color: kBeige,
          
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                Text(
                  'Rp ${price}',
                  style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w600),
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
                          "Alamat: ${product['owner']['province']}, ${product['owner']['district']}, ${product['owner']['village']}, ${product['owner']['city']}",
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {
            final phone = owner != null ? _safeString(owner['phone'], '') : '';
            if (phone.isNotEmpty) {
              openWhatsApp(phone, name);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Nomor telepon pemilik tidak tersedia')),
              );
            }
            print("OWNER DATA: $owner");
          },
          icon: const Icon(Icons.chat),
          label: const Text("Chat Pemilik via WhatsApp"),
        ),
      ),
    );
  }
}
