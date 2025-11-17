import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:loagapps/pages/home_page.dart';

Future<String?> loginUser(BuildContext context, String email, String password) async {
  final url = Uri.parse('http://192.168.1.6:8000/api/login');

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

    // Ambil token & userId
    final token = data['access_token'];
    final userId = data['user']['id'].toString();

    // Simpan ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['access_token']);
    await prefs.setString('user_id', data['user']['id'].toString());


    print("Login berhasil. userId: $userId");
    print("token : $token");

    // Kembalikan userId ke LoginPage
    return userId;
  } else {
    print('Login gagal (${response.statusCode}): ${response.body}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login gagal. Periksa email atau password.')),
    );
    return null; // login gagal
  }
}
