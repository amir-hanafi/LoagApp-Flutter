import 'dart:io';
import 'package:http/http.dart' as http;

Future<bool> uploadProduct({
  required String token,
  required String name,
  required String description,
  required String price,
  required File imageFile,
}) async {
  final uri = Uri.parse('http://10.187.243.197:8000/api/products');

  final request = http.MultipartRequest('POST', uri)
    ..headers['Authorization'] = 'Bearer $token'
    ..fields['name'] = name
    ..fields['description'] = description
    ..fields['price'] = price
    ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

  final response = await request.send();

  return response.statusCode == 201;
}
