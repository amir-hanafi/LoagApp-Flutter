import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

Future<String?> loginUser(
    BuildContext context, String email, String password) async {
  final url = Uri.parse('http://192.168.1.6:8000/api/login');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  print("STATUS LOGIN: ${response.statusCode}");
  print("LOGIN RESPONSE: ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    final token = data['access_token'];
    final userId = data['user']['id'].toString();

    // simpan token + userId
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("user_id", userId);

    return userId; // ← PENTING!!!
  } 
  else {
    // tampilkan error ke user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Login gagal: ${response.body}")),
    );

    return null;
  }
}

// ==========================================
// Fungsi ambil data user dari token
// ==========================================
Future<Map<String, dynamic>?> getUserData() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  if (token == null) return null;

  final response = await http.get(
    Uri.parse("http://192.168.1.6:8000/api/user"),
    headers: {"Authorization": "Bearer $token"},
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("Gagal ambil data user: ${response.body}");
    return null;
  }
}
