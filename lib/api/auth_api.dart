import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthApi {
  static const String baseUrl = 'http://10.187.243.197:8000/api';

  static Future<void> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      print('Login berhasil: ${response.body}');
    } else {
      print('Login gagal (${response.statusCode}): ${response.body}');
    }
  }
}
