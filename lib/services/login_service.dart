import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:loagapps/pages/home_page.dart';

Future<void> loginUser(BuildContext context, String email, String password) async {
  final url = Uri.parse('http://192.168.2.181:8000/api/login');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    // Simpan token ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['access_token']);

    // Navigasi ke halaman Home setelah login berhasil
    Navigator.pushReplacementNamed(context, '/home');

    print('Login berhasil: ${data['access_token']}');
  } else {
    print('Login gagal (${response.statusCode}): ${response.body}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login gagal. Periksa email atau password.')),
    );
  }
}
