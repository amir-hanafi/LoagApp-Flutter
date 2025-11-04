import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> deleteUser(int userId) async {
    final url = Uri.parse('http://192.168.1.14:8000/api/user/$userId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar( // ✅ sekarang context dikenali
        SnackBar(content: Text(data['message'])),
      );

      // misal setelah hapus akun, langsung ke login:
      Navigator.pushReplacementNamed(context, '/');
    } else {
      final error = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${error['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            deleteUser(4); // contoh id = 1
          },
          child: const Text('Hapus Akun'),
        ),
      ),
    );
  }
}
