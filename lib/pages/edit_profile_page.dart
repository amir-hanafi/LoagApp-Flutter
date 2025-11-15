import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  bool loading = false;

  Future<void> _updateProfile() async {
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('http://192.168.1.6:8000/api/profile/update'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'name': nameC.text,
        'email': emailC.text,
        if (passwordC.text.isNotEmpty) 'password': passwordC.text,
      },
    );

    setState(() => loading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui")),
      );
      Navigator.pop(context); // kembali ke ProfilePage
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(labelText: "Nama"),
            ),
            TextField(
              controller: emailC,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordC,
              decoration: const InputDecoration(labelText: "Password Baru (Opsional)"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text("Simpan Perubahan"),
                  ),
          ],
        ),
      ),
    );
  }
}
